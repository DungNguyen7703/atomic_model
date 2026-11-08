/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_fired_triggers
* Program name: Staging ECAT.QRTZ_FIRED_TRIGGERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)          AS sched_name
    , CAST(entry_id AS string)          AS entry_id
    , CAST(trigger_name AS string)      AS trigger_name
    , CAST(trigger_group AS string)     AS trigger_group
    , CAST(instance_name AS string)     AS instance_name
    , CAST(fired_time AS bigint)        AS fired_time
    , CAST(sched_time AS bigint)        AS sched_time
    , CAST(priority AS bigint)          AS priority
    , CAST(state AS string)             AS state
    , CAST(job_name AS string)          AS job_name
    , CAST(job_group AS string)         AS job_group
    , CAST(is_nonconcurrent AS string)  AS is_nonconcurrent
    , CAST(requests_recovery AS string) AS requests_recovery
FROM {{ source('source_ecat', 'raw_qrtz_fired_triggers') }}