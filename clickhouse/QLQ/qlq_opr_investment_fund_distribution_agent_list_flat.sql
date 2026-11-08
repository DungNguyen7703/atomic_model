-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_investment_fund_distribution_agent_list_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: khởi tạo từ flat-table/QLQ/02_populate_qlq_flat_tables.sql #15 (commit 2f62880d)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Investment Fund Distribution Agent List
    investment_fund_code,
    fund_distribution_agent_code,
    fund_distribution_agent_full_nm,
    src_stm_code

FROM {{ ref('dtm_opr_investment_fund_distribution_agent_list') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_FUD_AG_AGT'
