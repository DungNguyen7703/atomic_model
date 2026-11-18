-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_financial_report_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPR_SECURITIES_COMPANY_FINANCIAL_REPORT_HIST
    f.fin_rpt_hist_id,
    f.sc_code,
    f.sc_nm,
    f.rpt_year,
    f.rpt_period,
    f.rpt_code,
    f.period_nbr,
    f.revenue_amt,
    f.profit_after_tax_amt,
    f.roa_rate,
    f.roe_rate,
    f.submission_dt,
    f.submission_status_code,
    f.src_stm_code,
    f.preferred_report_ind

FROM {{ ref('dtm_opr_securities_company_financial_report_hist') }} f