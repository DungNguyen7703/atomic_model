-- ────────────────────────────────────────────────────────────
-- Model : qlkd_fct_securities_company_compliance_report_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Securities Company Compliance Report Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.report_tp_code,
    f.report_id,
    f.rpt_submission_status_code,
    f.sent_dt,
    f.submission_deadline_dt,
    f.rpt_year,
    f.rpt_period_tp_code,
    f.period_nbr,
    f.period_val,
    f.src_stm_code                  AS src_stm_code,
    f.created_dt,
    f.rpt_nm,
    f.end_dt,
    -- CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,
    -- SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.sc_short_nm                 AS sc_short_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_tp_nm               AS company_tp_nm,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.company_status_nm           AS company_status_nm,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm,
    sc_dim.src_stm_code                AS securities_company_src_stm_code

FROM {{ ref('dtm_fct_securities_company_compliance_report_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }} sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')