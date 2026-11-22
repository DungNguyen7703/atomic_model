-- [FIRST-TIME] ft_atm_cr_value: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_cr_value (config ft_target='cr_value', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ft_atm_cr_value
* Program name: [FIRST-TIME] Atomic Compliance Report Value
* Created by: tuan.nguyenvanb
* Created date: 2026-11-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-19		tuan.nguyenvanb		[MOI] Ban khoi tao cua atm_cr_value: doc ft_ods_tms_compliance_report_value (bo loc data_dt = etl_date).
*										Strategy APPEND (INSERT OVERWRITE dynamic theo partition src_stm_code = ghi de TOAN BANG) thay cho merge cua daily:
*										macro first-time voi merge se them cot ds_snpst_dt (khong co trong DDL cr_value) va nap full khong can MERGE.
*										DEDUPE 1 dong / cr_val_id (lay lan upload moi nhat): khoa gom form/column/row_index/ky bao cao, khong co submission
*										-> cung 1 khoa co the xuat hien o nhieu lan nop trong lich su. Bo LEFT JOIN ods structure (daily khong lay cot nao cua no).
*--------------------------------------------------------------------*
*/

WITH val AS (
    SELECT
        form_code
        , column_code
        , column_label
        , cell_val
        , submission_dt
        , row_index
        , submission_id
        , period_tp
        , period_val
        , period_year
        , submitter_tp
        , upload_dt
        , file_name
        , ROW_NUMBER() OVER (
            PARTITION BY concat_ws('-', form_code, column_code, row_index, period_tp, period_val, period_year)
            ORDER BY upload_dt DESC, submission_dt DESC, submission_id DESC
        ) AS rn
    FROM {{ ft_ref('ft_ods_tms_compliance_report_value') }}
    -- [BACKFILL-ORIG] WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('TMS_COMPLIANCE_REPORT_VALUE', "concat_ws('-', val.form_code, val.column_code, val.row_index, val.period_tp, val.period_val, val.period_year)") }} AS cr_val_id
    , CAST(concat_ws('-', val.form_code, val.column_code, val.row_index, val.period_tp, val.period_val, val.period_year) AS string)  AS cr_val_code
    , CAST('TMS_COMPLIANCE_REPORT_VALUE' AS string)                                                                                  AS src_stm_code
    , {{ generate_surrogate_key_bigint('TMS_COMPLIANCE_REPORT_STRUCTURE', "concat_ws('-', val.form_code, val.column_code)") }}       AS cr_structure_id
    , CAST(concat_ws('-', val.form_code, val.column_code) AS string)                                                                 AS cr_structure_code
    , CAST(val.form_code AS string)                                                                                                  AS form_code
    , CAST(val.column_code AS string)                                                                                                AS column_code
    , CAST(val.column_label AS string)                                                                                               AS column_label
    , CAST(val.cell_val AS string)                                                                                                   AS cell_val
    , CAST(val.submission_dt AS date)                                                                                                AS submission_dt
    , CAST(val.row_index AS bigint)                                                                                                  AS row_index
    , CAST(val.period_tp AS string)                                                                                                  AS rpt_period_tp_code
    , CAST(val.period_val AS int)                                                                                                    AS rpt_period_val
    , CAST(val.period_year AS int)                                                                                                   AS rpt_period_year
    , CAST(val.submitter_tp AS string)                                                                                               AS submitter_tp_code
    , CAST(val.upload_dt AS timestamp)                                                                                               AS upload_tms
    , CAST(val.file_name AS string)                                                                                                  AS file_nm
FROM val
WHERE val.rn = 1
