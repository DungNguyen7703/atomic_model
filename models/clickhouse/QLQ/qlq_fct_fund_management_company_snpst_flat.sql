-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_fund_management_company_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Fund Management Company Snapshot
    snpst_dt_dim_id,
    investment_fund_count,
    active_fund_management_company_count,
    foreign_fund_management_organization_unit_count,
    active_foreign_fund_management_organization_unit_count,
    pending_closure_foreign_fund_management_organization_unit_count,
    closed_foreign_fund_management_organization_unit_count,
    custodian_bank_count,
    TO_DATE(snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt

FROM {{ ref('dtm_fct_fund_management_company_snpst') }} 
