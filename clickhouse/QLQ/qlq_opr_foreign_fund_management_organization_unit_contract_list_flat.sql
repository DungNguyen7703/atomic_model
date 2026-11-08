-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_foreign_fund_management_organization_unit_contract_list_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: khởi tạo từ flat-table/QLQ/02_populate_qlq_flat_tables.sql #18 (commit d18cdaa0)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Foreign Fund Management Organization Unit Contract List
    fmr_submission_code,
    dynamic_row_nbr,
    foreign_fund_management_organization_unit_code,
    record_tp,
    period_tp_code,
    period_val,
    rpt_year,
    version_nbr,
    customer_nm,
    custody_account_nbr,
    contract_market_val_amt,
    src_stm_code

FROM {{ ref('dtm_opr_foreign_fund_management_organization_unit_contract_list') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_RPT_VALUES'
