-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_foreign_fund_management_organization_unit_snpst_flat
-- Type  : FACT
-- 2026-11-09 claude: thêm 4 cột VPĐD theo dtm_fct_foreign_fund_management_organization_unit_snpst (LLD commit 48c65dde, O_QLQ_82/83;
--                    schema-changing, cần ALTER bảng ClickHouse)
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Foreign Fund Management Organization Unit Snapshot
    snpst_dt_dim_id,
    branch_count,
    representative_office_count,
    active_representative_office_count,
    pending_closure_representative_office_count,
    closed_representative_office_count,
    TO_DATE(snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt

FROM {{ ref('dtm_fct_foreign_fund_management_organization_unit_snpst') }} 
