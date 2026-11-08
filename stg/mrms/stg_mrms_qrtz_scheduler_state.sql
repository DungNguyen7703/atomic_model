/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_scheduler_state
* Program name: Staging MRMS.QRTZ_SCHEDULER_STATE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)        AS sched_name
    , CAST(instance_name AS string)     AS instance_name
    , CAST(last_checkin_time AS bigint) AS last_checkin_time
    , CAST(checkin_interval AS bigint)  AS checkin_interval
FROM {{ source('source_mrms', 'raw_qrtz_scheduler_state') }}