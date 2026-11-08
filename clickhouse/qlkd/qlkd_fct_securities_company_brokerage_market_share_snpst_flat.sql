-- ────────────────────────────────────────────────────────────
-- Model : qlkd_fct_securities_company_brokerage_market_share_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FCT_SECURITIES_COMPANY_BROKERAGE_MARKET_SHARE_SNPST
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.report_quarter,
    f.trading_venue_nm,
    f.broker_nm,
    f.market_share_pct,
    f.src_stm_code,
    -- CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,
    -- SECURITIES COMPANY DIMENSION
    securities_c_dim.sc_id AS sc_id,
    securities_c_dim.sc_code AS sc_code,
    securities_c_dim.sc_nm AS sc_nm,
    securities_c_dim.sc_short_nm AS sc_short_nm,
    securities_c_dim.company_tp_code AS company_tp_code,
    securities_c_dim.company_tp_nm AS company_tp_nm,
    securities_c_dim.company_status_code AS company_status_code,
    securities_c_dim.company_status_nm AS company_status_nm,
    securities_c_dim.is_listed_indicator AS is_listed_indicator,
    securities_c_dim.stock_exchange_nm AS stock_exchange_nm,
    securities_c_dim.src_stm_code AS securities_c_dim_src_stm_code

FROM {{ ref('dtm_fct_securities_company_brokerage_market_share_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }} securities_c_dim
    ON securities_c_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')