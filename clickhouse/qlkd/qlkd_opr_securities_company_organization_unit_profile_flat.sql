-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_organization_unit_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Securities Company Organization Unit Profile
    o.sc_ou_code,
    o.sc_code,
    o.ou_tp_code,
    o.ou_nm,
    o.adr_val,
    o.decision_dt,
    o.director_nm,
    o.cl_firm_status_code,
    o.business_line_nm_list,
    o.src_stm_code

FROM {{ ref('dtm_opr_securities_company_organization_unit_profile') }} o