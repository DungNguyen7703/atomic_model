/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_blob_triggers
* Program name: Staging MRMS.QRTZ_BLOB_TRIGGERS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)    AS sched_name
    , CAST(trigger_name AS string)  AS trigger_name
    , CAST(trigger_group AS string) AS trigger_group
    , CAST(blob_data AS string)     AS blob_data
FROM {{ source('source_mrms', 'raw_qrtz_blob_triggers') }}