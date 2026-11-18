-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_management_company_employee_investor_account_list_flat
-- Type  : OPERATIONAL
-- 2026-10-29 claude: khởi tạo từ flat-table/QLQ/02_populate_qlq_flat_tables.sql #20 (commit cac5e35e, Nhóm 28, O_QLQ_55)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Management Company Employee Investor Account List
    fmc_employee_code,
    investor_account_nbr,
    identification_nbr,
    fmc_code,
    fmc_employee_full_nm,
    account_open_dt,
    account_update_dt,
    src_stm_code

FROM {{ ref('dtm_opr_fund_management_company_employee_investor_account_list') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_TL_PROFILES'
