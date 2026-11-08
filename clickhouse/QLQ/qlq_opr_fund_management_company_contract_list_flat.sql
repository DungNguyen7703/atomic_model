-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_management_company_contract_list_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: khởi tạo từ flat-table/QLQ/02_populate_qlq_flat_tables.sql #16 (commit d18cdaa0)
-- 2026-11-06 claude: O_QLQ_75 — đổi dynamic_row_nbr → table_idx cho khớp mart dtm_opr_fund_management_company_contract_list (schema-changing: cần ALTER RENAME COLUMN trên bảng CK)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Management Company Contract List
    fmr_submission_code,
    table_idx,
    investment_fund_code,
    fmc_id,
    fmc_code,
    record_tp,
    period_tp_code,
    period_val,
    rpt_year,
    version_nbr,
    customer_nm,
    custody_account_nbr,
    contract_market_val_amt,
    src_stm_code

FROM {{ ref('dtm_opr_fund_management_company_contract_list') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_RPT_VALUES'
