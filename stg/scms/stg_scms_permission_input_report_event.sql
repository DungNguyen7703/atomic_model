/*
*--------------------------------------------------------------------*
* Program code: stg_scms_permission_input_report_event
* Program name: Staging SCMS.PERMISSION_INPUT_REPORT_EVENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: id, permission_input_report_id, event_type_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(permission_input_report_id AS bigint) AS permission_input_report_id
    , CAST(event_type_id AS bigint)              AS event_type_id
FROM {{ source('source_scms', 'raw_permission_input_report_event') }}