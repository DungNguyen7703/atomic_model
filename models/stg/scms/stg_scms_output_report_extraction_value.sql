/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_extraction_value
* Program name: Staging SCMS.OUTPUT_REPORT_EXTRACTION_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (11 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: row_id.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(output_report_extraction_id AS bigint) AS output_report_extraction_id
    , CAST(form_report_id AS bigint)           AS form_report_id
    , CAST(form_sheet_id AS bigint)            AS form_sheet_id
    , CAST(form_sheet_row_id AS bigint)        AS form_sheet_row_id
    , CAST(form_sheet_column_id AS bigint)     AS form_sheet_column_id
    , CAST(form_sheet_cell_id AS bigint)       AS form_sheet_cell_id
    , CAST(row_id AS bigint)                      AS row_id
    , CAST(item_value AS string)               AS item_value
    , CAST(audited_report_id AS bigint)        AS audited_report_id
    , CAST(report_period AS string)            AS report_period
    , CAST(result AS string)                   AS result
    , CAST(export_file_path AS string)         AS export_file_path
    , CAST(error_message AS string)            AS error_message
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(user_id AS bigint)                  AS user_id
    , CAST(record_count AS bigint)             AS record_count
    , CAST(input_parameter AS string)          AS input_parameter
    , CAST(execution_time AS decimal(19,0))    AS execution_time
    , CAST(record_status AS bigint)            AS record_status
FROM {{ source('source_scms', 'raw_output_report_extraction_value') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1