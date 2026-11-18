-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Profile
    o.sc_senior_personnel_code,
    o.sc_code,
    o.full_nm,
    o.position_nm,
    o.identification_nbr,
    o.license_certificate_nbr,
    o.src_stm_code,
    o.appointment_dt

FROM {{ ref('dtm_opr_individual_profile') }} o