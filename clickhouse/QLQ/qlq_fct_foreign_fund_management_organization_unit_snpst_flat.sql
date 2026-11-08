-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_foreign_fund_management_organization_unit_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Foreign Fund Management Organization Unit Snapshot
    snpst_dt_dim_id,
    branch_count,
    TO_DATE(snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt

FROM {{ ref('dtm_fct_foreign_fund_management_organization_unit_snpst') }} 
