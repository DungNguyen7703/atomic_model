-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_report_value_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.submission_dt_dim_id,
    f.foreign_investor_report_structure_dim_id,
    f.rpt_log_id,
    f.dynamic_row_order,
    f.period_tp_code,
    f.period_val,
    f.rpt_year,
    f.submission_status_code,
    f.late_duration,
    f.total_row_ind,
    f.section_echo_ind,
    f.band_overflow_ind,
    f.static_copy_ind,
    f.rpt_marker_ind,
    f.val_raw,
    f.src_stm_code,
    submission_cal.cdr_dt AS submission_cdr_dt,
    str_dim.structure_code,
    str_dim.rpt_code,
    str_dim.rpt_nm,
    str_dim.report_type_nm,
    str_dim.legal_basis,
    str_dim.sheet_code,
    str_dim.sheet_nm,
    str_dim.section_id,
    str_dim.row_path,
    str_dim.column_path,
    str_dim.data_tp,
    str_dim.fir_structure_code,   -- [MỚI 2026-10-05] khớp ALTER TABLE ADD COLUMN,
    f.rpt_dt_dim_id,              -- [MỚI 2026-10-13] ngày báo cáo (role-playing, nullable) — 2 cột cuối khớp ALTER TABLE ADD COLUMN,
    NULLIF(
        rpt_cal.cdr_dt,
        CAST('1970-01-01' AS DATE)
    ) AS rpt_cdr_dt    -- LEFT JOIN không khớp (DayReport NULL) trả 1970-01-01 khi join_use_nulls=0 → ép về NULL

FROM {{ ref('dtm_fct_foreign_investor_report_value') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.submission_dt_dim_id
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
LEFT JOIN {{ ref('dtm_foreign_investor_report_structure_dim') }} str_dim
    ON str_dim.foreign_investor_report_structure_dim_id = f.foreign_investor_report_structure_dim_id
WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')