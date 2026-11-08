-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_organization_unit_service_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPR_SECURITIES_COMPANY_ORGANIZATION_UNIT_SERVICE
    f.organization_unit_service_id,
    f.sc_ou_code,
    f.cl_sc_firm_service_code,
    f.sc_code,
    f.ou_tp_code,
    f.catalog_code,
    f.decision_dt,
    f.src_stm_code

FROM {{ ref('dtm_opr_securities_company_organization_unit_service') }} f