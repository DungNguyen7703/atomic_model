-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_fund_distribution_agent_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Fund Distribution Agent Snapshot
    snpst_dt_dim_id,
    distribution_agent_count,
    TO_DATE(snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt

FROM {{ ref('dtm_fct_fund_distribution_agent_snpst') }}
