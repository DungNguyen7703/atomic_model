/*
*--------------------------------------------------------------------*
* Program code: stg_scms_permission_output_report_form
* Program name: Staging SCMS.PERMISSION_OUTPUT_REPORT_FORM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: id, permission_output_report_id, form_report_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                          AS id
    , CAST(permission_output_report_id AS bigint) AS permission_output_report_id
    , CAST(form_report_id AS bigint)              AS form_report_id
FROM {{ source('source_scms', 'raw_permission_output_report_form') }}