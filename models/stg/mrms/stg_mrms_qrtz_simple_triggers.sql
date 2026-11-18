/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_simple_triggers
* Program name: Staging MRMS.QRTZ_SIMPLE_TRIGGERS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)      AS sched_name
    , CAST(trigger_name AS string)    AS trigger_name
    , CAST(trigger_group AS string)   AS trigger_group
    , CAST(repeat_count AS int)       AS repeat_count
    , CAST(repeat_interval AS bigint) AS repeat_interval
    , CAST(times_triggered AS int)    AS times_triggered
FROM {{ source('source_mrms', 'raw_qrtz_simple_triggers') }}