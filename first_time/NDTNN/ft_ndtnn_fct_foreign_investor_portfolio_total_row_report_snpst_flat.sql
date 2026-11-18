-- [FIRST-TIME] ft_ndtnn_fct_foreign_investor_portfolio_total_row_report_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_fct_foreign_investor_portfolio_total_row_report_snpst_flat (config ft_target='ndtnn_fct_foreign_investor_portfolio_total_row_report_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_portfolio_total_row_report_snpst_flat
-- Type  : FACT
-- 2026-11-17 claude: [FIRST-TIME NDTNN] Tao moi: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- cdr_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay cua tung
-- dong (ft_day_column = snpst_cdr_dt) -> 1 partition = 1 ngay nhu daily.
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

FROM {{ ft_ref('ft_dtm_fct_foreign_investor_portfolio_total_row_report_snpst') }} f   -- [FT-NEW] daily: ref('dtm_fct_foreign_investor_portfolio_total_row_report_snpst')
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
-- [FT-ORIG] WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
