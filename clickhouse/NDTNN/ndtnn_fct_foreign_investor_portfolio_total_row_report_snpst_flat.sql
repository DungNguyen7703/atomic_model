-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_portfolio_total_row_report_snpst_flat
-- Type  : FACT
-- 2026-11-17 claude: [MOI, O_NDTNN_63] Dong tong sheet II (K_NDTNN_37, 38, 40) — loc theo rpt_cdr_dt o tang khai thac.
-- ────────────────────────────────────────────────────────────

SELECT
    f.fir_val_id,
    f.snpst_dt_dim_id,
    f.rpt_dt_dim_id,
    f.rpt_log_id,
    f.period_val,
    f.rpt_code,
    f.total_row_nm,
    f.asset_column_nm,
    f.asset_val,
    f.src_stm_code,
    submission_cal.cdr_dt AS snpst_cdr_dt,
    NULLIF(
        rpt_cal.cdr_dt,
        CAST('1970-01-01' AS DATE)
    ) AS rpt_cdr_dt

FROM {{ ref('dtm_fct_foreign_investor_portfolio_total_row_report_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')