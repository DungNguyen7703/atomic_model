-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_foreign_fund_management_organization_unit_profile_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: thêm 5 cột KPI báo cáo định kỳ theo dtm_opr_foreign_fund_management_organization_unit_profile (LLD commit 2f62880d)
--                    (schema-changing, cần ALTER bảng ClickHouse — ddl/20261014_qlq_ck_flat_sync.sql)
-- 2026-11-03 claude: bỏ 5 cột KPI báo cáo (chuyển sang fct_fund_management_rpt_cell_val) theo dtm_opr_foreign_fund_management_organization_unit_profile
--                    (LLD commit f2628ecf, O_QLQ_72; schema-changing, cần ALTER bảng ClickHouse — ddl/20261103_qlq_ck_flat_sync.sql)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Foreign Fund Management Organization Unit Profile
    foreign_fund_management_organization_unit_code,
    foreign_fund_management_organization_unit_full_nm,
    foreign_fund_management_organization_unit_short_nm,
    director_full_nm,
    src_stm_code

FROM {{ ref('dtm_opr_foreign_fund_management_organization_unit_profile') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'