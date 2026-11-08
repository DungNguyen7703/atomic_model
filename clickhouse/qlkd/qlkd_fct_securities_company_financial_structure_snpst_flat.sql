-- ────────────────────────────────────────────────────────────
-- Model : qlkd_fct_securities_company_financial_structure_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FCT_SECURITIES_COMPANY_FINANCIAL_STRUCTURE_SNPST
    f.rpt_input_val_id,
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.report_indicator_dim_id,
    f.rpt_year,
    f.rpt_period_tp_code,
    f.period_nbr,
    f.indicator_val_amt,
    f.rpt_code,
    f.legal_basis,
    f.rpt_input_submission_id,
    f.submission_dt,
    f.submission_status_code,
    f.src_stm_code,
    f.preferred_report_ind,
    f.rpt_input_submission_nbr,
    -- CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.cdr_dt AS snpst_cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,
    -- SECURITIES COMPANY DIMENSION
    sc_dim.sc_id AS sc_id,
    sc_dim.sc_code AS sc_code,
    sc_dim.sc_nm AS sc_nm,
    sc_dim.sc_short_nm AS sc_short_nm,
    sc_dim.company_tp_code AS company_tp_code,
    sc_dim.company_tp_nm   AS company_tp_nm,
    sc_dim.company_status_code AS company_status_code,
    sc_dim.company_status_nm AS company_status_nm,
    sc_dim.is_listed_indicator AS is_listed_indicator,
    sc_dim.stock_exchange_nm AS stock_exchange_nm,
    sc_dim.src_stm_code AS sc_dim_src_stm_code,
    -- REPORT INDICATOR DIMENSION
    ri_dim.sheet_id AS sheet_id,
    ri_dim.sheet_code AS sheet_code,
    ri_dim.cell_id AS cell_id,
    ri_dim.sc_rpt_id AS sc_rpt_id,
    ri_dim.src_stm_code AS ri_dim_src_stm_code

FROM {{ ref('dtm_fct_securities_company_financial_structure_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }} sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
LEFT JOIN {{ ref('dtm_report_indicator_dim') }} ri_dim
    ON ri_dim.report_indicator_dim_id = f.report_indicator_dim_id