-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_investment_fund_manager_list_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Investment Fund Manager List
    investment_fund_code,
    fmc_employee_code,
    fmc_employee_full_nm,
    src_stm_code

FROM {{ ref('dtm_opr_investment_fund_manager_list') }}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_FUND_TL_PRO'