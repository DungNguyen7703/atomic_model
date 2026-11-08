-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_compliance_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Securities Company Compliance History
    o.compliance_event_code,
    o.event_tp_code,
    o.form_tp_code,
    o.insp_decision_dt,
    o.decision_nbr,
    o.issued_dt,
    o.violation_behavior_nm,
    o.supplementary_penalty_nm,
    o.remedial_measure_nm,
    o.sc_code,
    o.src_stm_code,
    o.event_dt

FROM {{ ref('dtm_opr_securities_company_compliance_hist') }} o