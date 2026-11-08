-- [FIRST-TIME] ft_ndtnn_fct_foreign_investor_report_value_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_fct_foreign_investor_report_value_flat (config ft_target='ndtnn_fct_foreign_investor_report_value_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_report_value_flat
-- Type  : FACT
-- 2026-10-18 nghia.le: [FIX] rpt_cdr_dt thieu nullIf(..., toDate('1970-01-01')) - ban truoc do sot khi dong bo tu
-- daily, co nguy co ghi sentinel date 1970-01-01 thay vi NULL khi LEFT JOIN khong khop tren ClickHouse
-- (join_use_nulls=0). Them nullIf khop dung daily.
-- 2026-10-14 nghia.le: [DONG BO 01_create/02_populate] bo Foreign Investor Reporting Entity Dimension (cot FK + reporting_entity_*) khoi bang flat;
-- thêm cột rpt_dt_dim_id (trước rpt_cdr_dt) khớp DDL; rpt_cdr_dt NULL khi nguồn không có ngày chốt.
-- 2026-10-12 nghia.le: [FIRST-TIME NDTNN] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- cdr_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay cua tung
-- dong (ft_day_column) -> 1 partition = 1 ngay nhu daily. Dim doc bang MAIN giong daily.
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
    str_dim.fir_structure_code,   -- [MỚI 2026-10-05] cột cuối, khớp ALTER TABLE ADD COLUMN
    f.rpt_dt_dim_id,                     -- [MỚI 2026-10-14] FK ngày chốt số liệu (NULL khi nguồn không có DayReport)
    NULLIF(
        rpt_cal.cdr_dt,
        CAST('1970-01-01' AS DATE)
    ) AS rpt_cdr_dt   -- [MỚI 2026-10-13] ngày chốt số liệu, cột cuối — LEFT JOIN không khớp (DayReport NULL) trả 1970-01-01 khi join_use_nulls=0 → ép về NULL, khớp daily

FROM {{ ft_ref('ft_dtm_fct_foreign_investor_report_value') }} f   -- [FT-NEW] daily: ref('dtm_fct_foreign_investor_report_value')
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.submission_dt_dim_id
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
LEFT JOIN {{ ref('dtm_foreign_investor_report_structure_dim') }} str_dim
    ON str_dim.foreign_investor_report_structure_dim_id = f.foreign_investor_report_structure_dim_id
-- [FT-ORIG] WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
