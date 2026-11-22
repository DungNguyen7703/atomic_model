/*
*--------------------------------------------------------------------*
* Program code: atm_cr_value
* Program name: Atomic Compliance Report Value
* Created by: claude
* Created date: 2026-11-16
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-19		tuan.nguyenvanb		CTE st (ODS structure snapshot) loc ds_snpst_dt = etl_date: truoc day LEFT JOIN nhan dong theo so snapshot gay MERGE_CARDINALITY_VIOLATION.
* 2026-11-16		claude				[MOI] Tao model theo lld_TMS_COMPLIANCE_REPORT_VALUE.yaml (Classification -> upsert theo cr_val_id). Nguon ods_tms_report_value (truncate+insert, khong co data_dt -> doc toan bang). BK = form_code || column_code || row_index || submission_dt (yyyy-MM-dd) theo quyet dinh Data Modeler 2026-11-16.
*                                       [FK] cr_structure_id/cr_structure_code chi co gia tri khi (form_code, column_code) ton tai trong ods_tms_report, nguoc lai NULL (LLD T2-03: layout dong co cot ngoai header dau tien).
*                                       [DEDUPE] 2 lan nop cung bieu mau cung ngay se trung BK (LLD T2-01) -> giu dong upload_dt moi nhat, submission_id lon nhat de upsert khong loi MERGE_CARDINALITY_VIOLATION.
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
    FROM {{ ref('ods_tms_compliance_report_value') }}
    where data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

st AS (
    SELECT
        form_code
        , column_code
    FROM {{ ref('ods_tms_compliance_report_structure') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- [2026-11-19] ODS structure snapshot: chi lay ban chup ngay chay
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
LEFT JOIN st
    ON st.form_code = val.form_code
    AND st.column_code = val.column_code
