-- [FIRST-TIME] ft_dtm_fct_corporate_bond_market_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_corporate_bond_market_snpst (config ft_target='fct_corporate_bond_market_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_corporate_bond_market_snpst
* Program name: Fact Corporate Bond Market Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_corporate_bond_market_snpst (GIONG daily chay tung ngay giao dich):
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_listed_share_information / ft_atm_securities_trade), BO cac loc theo etl_date.
*									- append: ds_snpst_dt = ngay giao dich cua tung dong, dat CUOI SELECT; 1 dong / ngay co ban tin trai phieu (stock_tp_code = '1').
*									- niem yet: noi lsi_hnx theo (ma, ds_snpst_dt = trading_dt) cho MOI ngay; maturity_pressure_12_months_previous = gia tri tong cua PHIEN LIEN TRUOC
*									  (LAG tren chuoi ngay giao dich, khong cat cua so 15 ngay cua daily).
*									- rieng le: ky dang ky (nam-thang) = ky lon nhat <= thang cua TUNG ngay (as-of theo ngay, thay subquery MAX theo etl_date);
*									  previous = pressure rieng le tinh tren ngay phien truoc nhung dung CUNG ky dang ky cua ngay dang xet (giong daily).
*									- GTGD / YTM HCX HNX gom theo (ma, ngay), noi theo ngay; ytm noi theo isin_code, xep hang ban tin cuoi truoc roi moi loai yield NULL (nhu daily).
*									- 6 cot niem yet / rieng le giu o CUOI SELECT (truoc ds_snpst_dt).
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH se_tr_all AS (

    SELECT
        trading_dt
        , ticker_symbol AS symbol
        , maturity_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE stock_tp_code = '1'
        AND NOT (
            ticker_symbol RLIKE '^[A-Za-z]{2}GB'
            OR ticker_symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
            OR ticker_symbol RLIKE '^(HCM|HAN)'
        )

),

se_tr AS (

    SELECT trading_dt, symbol, maturity_dt
    FROM se_tr_all
    WHERE rn = 1

),

lsi_hnx AS (

    SELECT
        ticker_symbol
        , ds_snpst_dt
        , listed_share_quantity
    FROM {{ ft_ref('ft_atm_listed_share_information') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
    -- [BACKFILL-UAT-ORIG]     AND ds_snpst_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 15) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

agg_listed AS (

    SELECT
        se_tr.trading_dt
        , SUM(lsi_hnx.listed_share_quantity) AS outstanding_vol
        , SUM(
            CASE
                WHEN se_tr.maturity_dt > se_tr.trading_dt
                    AND se_tr.maturity_dt <= add_months(se_tr.trading_dt, 12)
                    THEN lsi_hnx.listed_share_quantity * 100000
                ELSE 0
            END
        ) AS maturity_pressure_12_months
    FROM se_tr
    INNER JOIN lsi_hnx
        ON lsi_hnx.ticker_symbol = se_tr.symbol
        AND lsi_hnx.ds_snpst_dt = se_tr.trading_dt
    GROUP BY se_tr.trading_dt

),

-- [BACKFILL-UAT-NEW] chuoi ngay giao dich + phien lien truoc (LAG tren chuoi ngay, khong loc etl_date)
trading_dates AS (

    SELECT
        trading_dt
        , LAG(trading_dt) OVER (ORDER BY trading_dt) AS prev_trading_dt
    FROM (SELECT DISTINCT trading_dt FROM se_tr) t

),

-- [BACKFILL-UAT-NEW] pr_latest as-of theo ngay: ky (nam-thang) lon nhat <= thang cua TUNG ngay (daily: subquery MAX theo etl_date)
pr_rows AS (

    SELECT
        CONCAT(rpt_year, LPAD(rpt_month, 2, '0')) AS ym
        , bond_code
        , maturity_dt
        , outstanding_bond_quantity
    FROM {{ ref('atm_private_corp_bond_registration') }}
    WHERE src_stm_code = 'HNX_PRIVATE_CORP_BOND_REGISTRATION'
    -- [BACKFILL-UAT-ORIG]     AND CONCAT(rpt_year, LPAD(rpt_month, 2, '0')) = (SELECT MAX(...) ... <= date_format(etl_date,'yyyyMM'))

),

pr_ym AS (

    SELECT DISTINCT ym FROM pr_rows

),

-- ky dang ky duoc chon cho (ngay) va cho (ngay phien truoc) theo ky cua NGAY DANG XET (giong daily: previous dung pr_latest cua etl_date)
day_ym AS (

    SELECT
        trading_dates.trading_dt
        , trading_dates.prev_trading_dt
        , MAX(pr_ym.ym) AS ym_sel
    FROM trading_dates
    INNER JOIN pr_ym
        ON pr_ym.ym <= date_format(trading_dates.trading_dt, 'yyyyMM')
    GROUP BY trading_dates.trading_dt, trading_dates.prev_trading_dt

),

agg_private AS (

    SELECT
        day_ym.trading_dt
        , SUM(pr_rows.outstanding_bond_quantity) AS outstanding_vol
        , SUM(
            CASE
                WHEN pr_rows.maturity_dt > day_ym.trading_dt
                    AND pr_rows.maturity_dt <= add_months(day_ym.trading_dt, 12)
                    THEN pr_rows.outstanding_bond_quantity * 100000
                ELSE 0
            END
        ) AS maturity_pressure_12_months
        , SUM(
            CASE
                WHEN pr_rows.maturity_dt > day_ym.prev_trading_dt
                    AND pr_rows.maturity_dt <= add_months(day_ym.prev_trading_dt, 12)
                    THEN pr_rows.outstanding_bond_quantity * 100000
                ELSE 0
            END
        ) AS maturity_pressure_12_months_prev
    FROM day_ym
    INNER JOIN pr_rows
        ON pr_rows.ym = day_ym.ym_sel
    GROUP BY day_ym.trading_dt

),

with_lag AS (

    SELECT
        trading_dates.trading_dt
        , COALESCE(agg_listed.outstanding_vol, 0) + COALESCE(agg_private.outstanding_vol, 0) AS outstanding_vol
        , COALESCE(agg_listed.maturity_pressure_12_months, 0) + COALESCE(agg_private.maturity_pressure_12_months, 0) AS maturity_pressure_12_months
        , COALESCE(agg_listed.outstanding_vol, 0) AS outstanding_vol_listed
        , COALESCE(agg_private.outstanding_vol, 0) AS outstanding_vol_private
        , COALESCE(agg_listed.maturity_pressure_12_months, 0) AS maturity_pressure_12_months_listed
        , COALESCE(agg_private.maturity_pressure_12_months, 0) AS maturity_pressure_12_months_private
        , CASE
            WHEN trading_dates.prev_trading_dt IS NULL THEN NULL
            ELSE COALESCE(agg_listed_prev.maturity_pressure_12_months, 0) + COALESCE(agg_private.maturity_pressure_12_months_prev, 0)
          END AS maturity_pressure_12_months_previous
    FROM trading_dates
    LEFT JOIN agg_listed
        ON agg_listed.trading_dt = trading_dates.trading_dt
    LEFT JOIN agg_listed agg_listed_prev
        ON agg_listed_prev.trading_dt = trading_dates.prev_trading_dt
    LEFT JOIN agg_private
        ON agg_private.trading_dt = trading_dates.trading_dt

),

bond_trade AS (

    SELECT
        trade_dt
        , security_symbol_code
        , SUM(execution_val) AS gtgd_ma_tp
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE market_id_code = 'HCX'
        AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
    -- [BACKFILL-UAT-ORIG]     AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY
        trade_dt
        , security_symbol_code

),

bond_trade_total AS (

    SELECT
        trade_dt
        , SUM(gtgd_ma_tp) AS bond_trading_val
    FROM bond_trade
    GROUP BY trade_dt

),

ytm_ranked AS (

    SELECT
        isin_code AS symbol
        , trading_dt
        , yield
        , ROW_NUMBER() OVER (
            PARTITION BY isin_code, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND stock_tp_code = '1'
    -- [BACKFILL-UAT-ORIG]     AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

ytm_weighted AS (

    SELECT
        bond_trade.trade_dt
        , SUM(ytm_ranked.yield * bond_trade.gtgd_ma_tp) / NULLIF(SUM(bond_trade.gtgd_ma_tp), 0) AS bond_yield_weighted_average
    FROM bond_trade
    INNER JOIN ytm_ranked
        ON ytm_ranked.symbol = bond_trade.security_symbol_code
        AND ytm_ranked.trading_dt = bond_trade.trade_dt
        AND ytm_ranked.rn = 1
        AND ytm_ranked.yield IS NOT NULL
    GROUP BY bond_trade.trade_dt

)

SELECT
    CAST(date_format(with_lag.trading_dt, 'yyyyMMdd') AS string)                AS snpst_dt_dim_id,
    CAST(100000 AS decimal(23,2))                                               AS par_val,
    CAST(with_lag.outstanding_vol AS decimal(23,2))                             AS outstanding_vol,
    CAST(100000 * with_lag.outstanding_vol AS decimal(23,2))                    AS bond_outstanding_val,
    CAST(with_lag.maturity_pressure_12_months AS decimal(23,2))                 AS maturity_pressure_12_months,
    CAST(with_lag.maturity_pressure_12_months_previous AS decimal(23,2))        AS maturity_pressure_12_months_previous,
    CAST(
        (with_lag.maturity_pressure_12_months - with_lag.maturity_pressure_12_months_previous)
        / NULLIF(with_lag.maturity_pressure_12_months_previous, 0) * 100
    AS decimal(5,2))                                                            AS maturity_pressure_growth_percentage,
    CAST(bond_trade_total.bond_trading_val AS decimal(23,2))                    AS bond_trading_val,
    CAST(ytm_weighted.bond_yield_weighted_average AS decimal(9,4))              AS bond_yield_weighted_average,
    CAST(with_lag.outstanding_vol_listed AS decimal(23,2))                      AS outstanding_vol_listed,
    CAST(with_lag.outstanding_vol_private AS decimal(23,2))                     AS outstanding_vol_private,
    CAST(100000 * with_lag.outstanding_vol_listed AS decimal(23,2))             AS bond_outstanding_val_listed,
    CAST(100000 * with_lag.outstanding_vol_private AS decimal(23,2))            AS bond_outstanding_val_private,
    CAST(with_lag.maturity_pressure_12_months_listed AS decimal(23,2))          AS maturity_pressure_12_months_listed,
    CAST(with_lag.maturity_pressure_12_months_private AS decimal(23,2))         AS maturity_pressure_12_months_private,
    CAST(with_lag.trading_dt AS date)                                           AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM with_lag
LEFT JOIN bond_trade_total
    ON bond_trade_total.trade_dt = with_lag.trading_dt
LEFT JOIN ytm_weighted
    ON ytm_weighted.trade_dt = with_lag.trading_dt
-- [BACKFILL-UAT-ORIG] WHERE with_lag.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
