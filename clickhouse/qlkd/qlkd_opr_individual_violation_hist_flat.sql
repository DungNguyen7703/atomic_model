-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_violation_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Violation History
    o.pd_subject_behavior_code,
    o.pd_code,
    o.identification_nbr,
    o.decision_nbr,
    o.issued_dt,
    o.violation_behavior_nm,
    o.penalty_tp_nm,
    o.decision_status_code,
    o.src_stm_code

FROM {{ ref('dtm_opr_individual_violation_hist') }} o