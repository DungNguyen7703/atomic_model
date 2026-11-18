-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_investment_fund_profile_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: thêm distribution_agent_count, net_asset_val_amt, year_to_dt_profit_amt theo dtm_opr_investment_fund_profile
--                    (LLD commit 2f62880d; schema-changing, cần ALTER bảng ClickHouse — ddl/20261014_qlq_ck_flat_sync.sql)
-- 2026-10-24: Bổ sung investment_fund_short_nm, đổi fmc_short_nm -> fmc_full_nm khớp với dtm_opr_investment_fund_profile
-- 2026-11-03 claude: bỏ net_asset_val_amt, year_to_dt_profit_amt (chuyển sang fct_fund_management_rpt_cell_val) theo dtm_opr_investment_fund_profile
--                    (LLD commit f2628ecf, O_QLQ_72; schema-changing, cần ALTER bảng ClickHouse — ddl/20261103_qlq_ck_flat_sync.sql)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Investment Fund Profile
    investment_fund_code,
    investment_fund_full_nm,
    investment_fund_short_nm,
    fund_tp_code,
    fmc_full_nm,
    custodian_bank_full_nm,
    representative_board_member_count,
    manager_count,
    outstanding_unit_quantity,
    distribution_agent_count,
    src_stm_code

FROM {{ ref('dtm_opr_investment_fund_profile') }}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_FUNDS'