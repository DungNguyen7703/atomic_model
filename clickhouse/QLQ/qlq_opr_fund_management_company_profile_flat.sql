-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_management_company_profile_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: thêm 6 cột KPI báo cáo định kỳ theo dtm_opr_fund_management_company_profile (LLD commit 2f62880d)
--                    (schema-changing, cần ALTER bảng ClickHouse — ddl/20261014_qlq_ck_flat_sync.sql)
-- 2026-10-24: Bổ sung operation_status_nm, legal_representative_nm; thay rank_index bằng rating_class_code
--             khớp với dtm_opr_fund_management_company_profile
-- 2026-10-30 claude (sync): bỏ 7 cột KPI báo cáo theo LLD commit 8d4fb63a (O_QLQ_59) — charter_capital_amt,
--                    certified_practitioner_staff_count, assets_under_management_amt, capital_adequacy_ratio,
--                    net_profit_after_tax_amt, owner_equity_amt, portfolio_management_contract_count
--                    (schema-changing, cần ALTER DROP COLUMN bảng ClickHouse trước khi chạy)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Management Company Profile
    fmc_code,
    fmc_id,
    fmc_full_nm,
    fmc_short_nm,
    operation_status_nm,
    legal_representative_nm,
    fund_count,
    rating_class_code,
    total_score_amt,
    src_stm_code

FROM {{ ref('dtm_opr_fund_management_company_profile') }}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_SECURITIES'