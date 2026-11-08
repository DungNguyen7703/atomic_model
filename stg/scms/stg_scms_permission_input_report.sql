/*
*--------------------------------------------------------------------*
* Program code: stg_scms_permission_input_report
* Program name: Staging SCMS.PERMISSION_INPUT_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: id, user_id, created_by, last_modified_by.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(user_id AS bigint)                AS user_id
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(created_by AS bigint)             AS created_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(last_modified_by AS bigint)       AS last_modified_by
FROM {{ source('source_scms', 'raw_permission_input_report') }}