/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_fired_triggers
* Program name: Staging MRMS.QRTZ_FIRED_TRIGGERS
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
    , CAST(entry_id AS string)          AS entry_id
    , CAST(trigger_name AS string)      AS trigger_name
    , CAST(trigger_group AS string)     AS trigger_group
    , CAST(instance_name AS string)     AS instance_name
    , CAST(fired_time AS bigint)        AS fired_time
    , CAST(sched_time AS bigint)        AS sched_time
    , CAST(priority AS int)             AS priority
    , CAST(state AS string)             AS state
    , CAST(job_name AS string)          AS job_name
    , CAST(job_group AS string)         AS job_group
    , CAST(is_nonconcurrent AS string)  AS is_nonconcurrent
    , CAST(requests_recovery AS string) AS requests_recovery
FROM {{ source('source_mrms', 'raw_qrtz_fired_triggers') }}