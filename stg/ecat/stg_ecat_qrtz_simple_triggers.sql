/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_simple_triggers
* Program name: Staging ECAT.QRTZ_SIMPLE_TRIGGERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)        AS sched_name
    , CAST(trigger_name AS string)    AS trigger_name
    , CAST(trigger_group AS string)   AS trigger_group
    , CAST(repeat_count AS int)       AS repeat_count
    , CAST(repeat_interval AS bigint) AS repeat_interval
    , CAST(times_triggered AS bigint) AS times_triggered
FROM {{ source('source_ecat', 'raw_qrtz_simple_triggers') }}