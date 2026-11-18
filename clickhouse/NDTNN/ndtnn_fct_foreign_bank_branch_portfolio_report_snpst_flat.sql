-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_bank_branch_portfolio_report_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.fir_val_id,
    f.snpst_dt_dim_id,
    f.rpt_dt_dim_id,
    f.rpt_log_id,
    f.period_val,
    f.rpt_code,
    f.asset_group_nm,
    f.closing_balance_val,
    f.src_stm_code,
    submission_cal.cdr_dt AS snpst_cdr_dt,
    NULLIF(
        rpt_cal.cdr_dt,
        CAST('1970-01-01' AS DATE)
    ) AS rpt_cdr_dt

FROM {{ ref('dtm_fct_foreign_bank_branch_portfolio_report_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')