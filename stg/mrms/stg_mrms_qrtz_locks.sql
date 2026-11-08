/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_locks
* Program name: Staging MRMS.QRTZ_LOCKS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string) AS sched_name
    , CAST(lock_name AS string)  AS lock_name
FROM {{ source('source_mrms', 'raw_qrtz_locks') }}