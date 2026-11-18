/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_triggers
* Program name: Staging MRMS.QRTZ_TRIGGERS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)     AS sched_name
    , CAST(trigger_name AS string)   AS trigger_name
    , CAST(trigger_group AS string)  AS trigger_group
    , CAST(job_name AS string)       AS job_name
    , CAST(job_group AS string)      AS job_group
    , CAST(description AS string)    AS description
    , CAST(next_fire_time AS bigint) AS next_fire_time
    , CAST(prev_fire_time AS bigint) AS prev_fire_time
    , CAST(priority AS int)          AS priority
    , CAST(trigger_state AS string)  AS trigger_state
    , CAST(trigger_type AS string)   AS trigger_type
    , CAST(start_time AS bigint)     AS start_time
    , CAST(end_time AS bigint)       AS end_time
    , CAST(calendar_name AS string)  AS calendar_name
    , CAST(misfire_instr AS int)     AS misfire_instr
    , CAST(job_data AS string)       AS job_data
FROM {{ source('source_mrms', 'raw_qrtz_triggers') }}