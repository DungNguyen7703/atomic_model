-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_practitioner_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPR_SECURITIES_COMPANY_PRACTITIONER_PROFILE
    f.prac_profile_id,
    f.sc_code,
    f.sc_nm,
    f.rpt_code,
    f.legal_basis,
    f.rpt_year,
    f.rpt_period_tp_code,
    f.period_nbr,
    f.total_employee_cnt,
    f.licensed_practitioner_cnt,
    f.unlicensed_practitioner_cnt,
    f.brokerage_practitioner_cnt,
    f.underwriting_practitioner_cnt,
    f.advisory_practitioner_cnt,
    f.proprietary_practitioner_cnt,
    f.deriv_brokerage_practitioner_cnt,
    f.deriv_advisory_practitioner_cnt,
    f.deriv_proprietary_practitioner_cnt,
    f.submission_dt,
    f.end_dt,
    f.submission_status_code,
    f.src_stm_code

FROM {{ ref('dtm_opr_securities_company_practitioner_profile') }} f