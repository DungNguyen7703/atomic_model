-- [FIRST-TIME] ft_dtm_fct_proprietary_net_trade_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_proprietary_net_trade_snpst (config ft_target='fct_proprietary_net_trade_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_proprietary_net_trade_snpst
* Program name: Fact Proprietary Net Trade Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_proprietary_net_trade_snpst:
*									- doc atomic qua ft_ref (ft_atm_securities_trade), BO loc trade_dt = etl_date de nap toan bo lich su 1 lan.
*									- append: ds_snpst_dt = trade_dt cua tung dong (daily snapshot: ds_snpst_dt = etl_date = ngay giao dich), dat CUOI SELECT.
*									- GROUP BY da co trade_dt nen khong can them khoa ngay.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH se_tr AS (
    SELECT
        trade_dt
        , security_symbol_code
        , execution_val
        , buy_account_nbr
        , sell_account_nbr
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE market_id_code IN ('STK','STX','UPX')
),

agg AS (
    SELECT
        se_tr.trade_dt
        , se_tr.security_symbol_code
        , SUM(CASE WHEN SUBSTR(se_tr.buy_account_nbr, 4, 1) IN ('A','E','P') THEN se_tr.execution_val ELSE 0 END)  AS proprietary_buy_val
        , SUM(CASE WHEN SUBSTR(se_tr.sell_account_nbr, 4, 1) IN ('A','E','P') THEN se_tr.execution_val ELSE 0 END) AS proprietary_sell_val
    FROM se_tr
    GROUP BY
        se_tr.trade_dt
        , se_tr.security_symbol_code
)

SELECT
    CAST(date_format(agg.trade_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(agg.security_symbol_code AS string)               AS security_symbol_code,
    CAST(agg.proprietary_buy_val AS decimal(23,2))         AS proprietary_buy_val,
    CAST(agg.proprietary_sell_val AS decimal(23,2))        AS proprietary_sell_val,
    CAST(agg.proprietary_buy_val - agg.proprietary_sell_val AS decimal(23,2)) AS proprietary_net_val,
    CAST(agg.trade_dt AS date)                             AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM agg
