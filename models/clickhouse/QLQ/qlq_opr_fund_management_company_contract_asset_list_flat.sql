-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_management_company_contract_asset_list_flat
-- Type  : OPERATIONAL
-- 2026-11-11 claude: khởi tạo theo LLD commit f5a29074 (O_QLQ_86) — bảng flat mới hoàn toàn (cần CREATE TABLE trên CK)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Management Company Contract Asset List
    fmr_submission_code,
    table_idx,
    asset_indicator_code,
    investment_fund_code,
    fmc_id,
    fmc_code,
    record_tp,
    period_tp_code,
    period_val,
    rpt_year,
    version_nbr,
    asset_market_val_amt,
    src_stm_code

FROM {{ ref('dtm_opr_fund_management_company_contract_asset_list') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_RPT_VALUES'
