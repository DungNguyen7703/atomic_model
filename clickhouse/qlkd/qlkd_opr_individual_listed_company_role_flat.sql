-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_listed_company_role_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Listed Company Role
    o.listed_company_role_id,
    o.individual_identification_nbr,
    o.individual_full_nm,
    o.org_code,
    o.org_nm,
    o.org_tp_nm,
    o.role_nm,
    o.shares_held_qty,
    o.status_nm,
    o.effective_from_dt,
    o.effective_to_dt,
    o.src_stm_code

FROM {{ ref('dtm_opr_individual_listed_company_role') }} o