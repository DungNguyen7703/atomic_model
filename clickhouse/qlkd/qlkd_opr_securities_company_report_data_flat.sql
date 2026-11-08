-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_report_data_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPR_SECURITIES_COMPANY_REPORT_DATA
    f.rpt_cell_val_id,
    f.rpt_input_submission_id,
    f.rpt_input_submission_code,
    f.sc_code,
    f.sc_nm,
    f.rpt_code,
    f.rpt_year,
    f.rpt_period,
    f.period_nbr,
    f.sheet_id,
    f.sheet_code,
    f.section_id,
    f.cell_id,
    f.row_nbr,
    f.item_val,
    f.submission_dt,
    f.submission_deadline_dt,
    f.submission_status_code,
    f.src_stm_code

FROM {{ ref('dtm_opr_securities_company_report_data') }} f