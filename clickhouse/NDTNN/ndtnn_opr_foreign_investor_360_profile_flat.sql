-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_opr_foreign_investor_360_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Operational Foreign Investor 360 Profile
    o.investor_code,
    o.investor_nm,
    o.nationality_code,
    o.nationality_nm,
    o.investor_tp_code,
    o.investor_tp_nm,
    o.director_nm,
    o.custodian_bank_nm,
    o.src_stm_code,
    o.investor_status_code,
    o.investor_status_nm,
    o.identification_nbr,
    o.investor_object_tp_code

FROM {{ ref('dtm_opr_foreign_investor_360_profile') }} o