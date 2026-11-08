-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_opr_investor_compliance_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Operational Investor Compliance History
    o.investor_compliance_hist_code,
    o.subject_nm,
    o.subject_id_nbr,
    o.issued_dt,
    o.penalty_tp_nm,
    o.description,
    o.life_cycle_status_code,
    o.src_stm_code

FROM {{ ref('dtm_opr_investor_compliance_hist') }} o