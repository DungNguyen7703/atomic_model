-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_foreign_fund_management_representative_office_profile_flat
-- Type  : OPERATIONAL
-- 2026-11-09 claude: khởi tạo theo dtm_opr_foreign_fund_management_representative_office_profile (LLD commit 48c65dde, O_QLQ_83)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Foreign Fund Management Representative Office Profile
    foreign_fund_management_organization_unit_code,
    foreign_fund_management_organization_unit_full_nm,
    operation_status_nm,
    license_nbr,
    license_dt,
    address,
    tax_id_nbr,
    src_stm_code

FROM {{ ref('dtm_opr_foreign_fund_management_representative_office_profile') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_FOR_BRCH'
