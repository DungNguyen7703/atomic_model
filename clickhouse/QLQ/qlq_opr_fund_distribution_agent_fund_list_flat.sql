-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_distribution_agent_fund_list_flat
-- Type  : OPERATIONAL
-- 2026-10-24: Bổ sung securities_distribution_agent_code khớp với dtm_opr_fund_distribution_agent_fund_list
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Distribution Agent Fund List
    fund_distribution_agent_code,
    investment_fund_code,
    investment_fund_full_nm,
    securities_distribution_agent_code,
    src_stm_code

FROM {{ ref('dtm_opr_fund_distribution_agent_fund_list') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_FUD_AG_AGT'