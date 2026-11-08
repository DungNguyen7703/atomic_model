/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_cron_triggers
* Program name: Staging ECAT.QRTZ_CRON_TRIGGERS
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
    , CAST(cron_expression AS string) AS cron_expression
    , CAST(time_zone_id AS string)    AS time_zone_id
FROM {{ source('source_ecat', 'raw_qrtz_cron_triggers') }}