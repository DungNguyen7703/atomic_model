/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_scheduler_state
* Program name: Staging ECAT.QRTZ_SCHEDULER_STATE
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
    , CAST(instance_name AS string)     AS instance_name
    , CAST(last_checkin_time AS bigint) AS last_checkin_time
    , CAST(checkin_interval AS bigint)  AS checkin_interval
FROM {{ source('source_ecat', 'raw_qrtz_scheduler_state') }}