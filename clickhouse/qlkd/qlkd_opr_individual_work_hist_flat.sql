-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_work_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Work History
    o.sc_senior_personnel_code,
    o.individual_identification_nbr,
    o.sc_code,
    o.position_nm,
    o.work_start_dt,
    o.dismissal_dt,
    o.resignation_dt,
    o.employment_status_code,
    o.personnel_status_code,
    o.src_stm_code

FROM {{ ref('dtm_opr_individual_work_hist') }} o