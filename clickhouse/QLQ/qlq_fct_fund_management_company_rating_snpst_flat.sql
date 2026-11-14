-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_fund_management_company_rating_snpst_flat
-- Type  : FACT
-- 2026-11-11 claude (sync): tạo mới theo LLD commit 56eb71c6 (O_QLQ_88) — flat mới, cần CREATE TABLE ClickHouse
--                    (ddl/20261111_qlq_rating_snpst_sync.sql). snpst_cdr_dt = ngày cuối kỳ đánh giá (quy ước snpst_cdr_dt cho Fact snapshot)
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Fund Management Company Rating Snapshot
    fund_management_company_rating_snpst_id,
    snpst_dt_dim_id,
    fmc_id,
    member_rating_code,
    rpt_year,
    rating_period_code,
    rating_period_end_dt,
    rating_class_code,
    total_score_amt,
    rating_finalized_flag,
    src_stm_code,
    TO_DATE(snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt

FROM {{ ref('dtm_fct_fund_management_company_rating_snpst') }}
