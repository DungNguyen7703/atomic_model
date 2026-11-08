-- [FIRST-TIME] ft_dtm_fct_investor_flow_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_investor_flow_snpst (config ft_target='fct_investor_flow_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investor_flow_snpst
* Program name: Fact Investor Flow Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_investor_flow_snpst:
*									- doc so lenh qua ft_ref(ft_atm_securities_trade), BO loc trade_dt = etl_date de nap toan bo lich su 1 lan.
*									- append: ds_snpst_dt = trade_dt cua tung dong (daily snapshot: ds_snpst_dt = etl_date = ngay giao dich), dat CUOI SELECT.
*									- gom theo (trade_dt) da co san; mau so trading_val_ratio la window PARTITION BY snpst_dt_dim_id (theo ngay) nen khong doi.
*									- inv_acc (atm_open_investor_account, ban ghi moi nhat theo so TK) giu nguyen nhu cac ban ft GSTT: phan loai NDT theo ban ghi
*									  moi nhat cua tai khoan, khong as-of theo ngay (HAN CHE da biet).
*--------------------------------------------------------------------*
* 2026-11-03		tuan.nguyenvanb		[SUA] atm_open_investor_account tren Spark khong con cot ds_snpst_dt (chi con partition open_dt): bo ds_snpst_dt khoi ORDER BY cua CTE inv_acc, chi xep theo open_dt DESC. Khong doi cot/kieu.
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH
inv_acc AS (

    SELECT investor_account_nbr, investor_tp_code
    FROM (
        SELECT
            investor_account_nbr
            , investor_tp_code
            , ROW_NUMBER() OVER (PARTITION BY investor_account_nbr ORDER BY open_dt DESC) AS rn
        FROM {{ ref('atm_open_investor_account') }}
        WHERE investor_account_nbr IS NOT NULL
    ) x
    WHERE rn = 1

),

tr AS (

    SELECT
        t.trade_dt
        , t.execution_vol
        , t.execution_price
        , t.buy_account_nbr
        , t.sell_account_nbr
        , vsdc_buy.investor_tp_code  AS buy_vsdc_tp_code
        , vsdc_sell.investor_tp_code AS sell_vsdc_tp_code
    FROM {{ ft_ref('ft_atm_securities_trade') }} t   -- [BACKFILL-UAT-NEW] ft_ref
    LEFT JOIN inv_acc vsdc_buy
        ON vsdc_buy.investor_account_nbr = t.buy_account_nbr
    LEFT JOIN inv_acc vsdc_sell
        ON vsdc_sell.investor_account_nbr = t.sell_account_nbr
    -- [BACKFILL-UAT-ORIG] WHERE t.trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE t.market_id_code IN ('STK','STX','UPX')

),

grouped AS (

    SELECT
        trade_dt

        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_buy_val
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_sell_val

        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('A','E','P')
            THEN execution_vol * execution_price ELSE 0 END)          AS proprietary_buy_val
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('A','E','P')
            THEN execution_vol * execution_price ELSE 0 END)          AS proprietary_sell_val

        , SUM(CASE WHEN buy_vsdc_tp_code = 3
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_individual_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 3
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_individual_sell_val

        , SUM(CASE WHEN buy_vsdc_tp_code = 4
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_individual_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 4
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_individual_sell_val

        , SUM(CASE WHEN buy_vsdc_tp_code = 5
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_institution_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 5
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_institution_sell_val

        , SUM(CASE WHEN buy_vsdc_tp_code = 6
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_institution_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 6
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_institution_sell_val

    FROM tr
    GROUP BY trade_dt

),

pivoted AS (

    SELECT trade_dt, CAST('FOREIGN' AS string) AS investor_group_code, foreign_buy_val AS buy_val, foreign_sell_val AS sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('PROPRIETARY' AS string), proprietary_buy_val, proprietary_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('DOMESTIC_INDIVIDUAL' AS string), domestic_individual_buy_val, domestic_individual_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('FOREIGN_INDIVIDUAL' AS string), foreign_individual_buy_val, foreign_individual_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('DOMESTIC_INSTITUTION' AS string), domestic_institution_buy_val, domestic_institution_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('FOREIGN_INSTITUTION' AS string), foreign_institution_buy_val, foreign_institution_sell_val FROM grouped

),

joined AS (

    SELECT
        pivoted.trade_dt
        , CAST(date_format(pivoted.trade_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id
        , investor_group_dim.investor_group_dim_id
        , pivoted.investor_group_code
        , pivoted.buy_val
        , pivoted.sell_val
    FROM pivoted
    INNER JOIN {{ ref('dtm_investor_group_dim') }} investor_group_dim
        ON investor_group_dim.investor_group_code = pivoted.investor_group_code

),

ratio_base AS (

    SELECT
        joined.*
        , SUM(CASE WHEN joined.investor_group_code IN
                ('DOMESTIC_INDIVIDUAL','FOREIGN_INDIVIDUAL','DOMESTIC_INSTITUTION','FOREIGN_INSTITUTION')
            THEN joined.buy_val + joined.sell_val END)
            OVER (PARTITION BY joined.snpst_dt_dim_id)                AS total_val_4_groups
    FROM joined

)

SELECT
    CAST(ratio_base.snpst_dt_dim_id AS string)                  AS snpst_dt_dim_id,
    CAST(ratio_base.investor_group_dim_id AS string)           AS investor_group_dim_id,
    CAST(ratio_base.buy_val AS decimal(23,2))                   AS buy_val,
    CAST(ratio_base.sell_val AS decimal(23,2))                  AS sell_val,
    CAST(ratio_base.buy_val - ratio_base.sell_val AS decimal(23,2)) AS net_flow_val,
    CAST(
        (ratio_base.buy_val + ratio_base.sell_val)
        / NULLIF(ratio_base.total_val_4_groups, 0) * 100
    AS decimal(5,2))                                            AS trading_val_ratio,
    CAST(ratio_base.trade_dt AS date)                           AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM ratio_base
