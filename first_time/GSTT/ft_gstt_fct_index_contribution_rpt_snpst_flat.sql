-- [FIRST-TIME] ft_gstt_fct_index_contribution_rpt_snpst_flat (ft_target = gstt_fct_index_contribution_rpt_snpst_flat)
-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_index_contribution_rpt_snpst_flat
-- Type  : FACT
-- 2026-11-17 claude: [MOI, O_GSTT_87] Flat table Fact Index Contribution Report Snapshot x Calendar Date (ngay du lieu).
-- Partition theo cdr_dt = ngay du lieu cua dong bao cao (cung quy uoc cac fact snapshot GSTT); ds_snpst_dt = cdr_dt (macro ft_ck_by_day).
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    f.index_contribution_rpt_id,
    f.security_trading_snpst_dim_id,
    f.snpst_dt_dim_id,
    f.ticker_symbol,
    f.contribution_percentage,
    f.submission_dt,
    f.submitter_tp_code,
    f.form_code,
    -- CALENDAR DATE (ngay du lieu)
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date

FROM {{ ft_ref('ft_dtm_fct_index_contribution_rpt_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
