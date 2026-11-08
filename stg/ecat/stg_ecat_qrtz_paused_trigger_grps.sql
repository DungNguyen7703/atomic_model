/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_paused_trigger_grps
* Program name: Staging ECAT.QRTZ_PAUSED_TRIGGER_GRPS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)      AS sched_name
    , CAST(trigger_group AS string) AS trigger_group
FROM {{ source('source_ecat', 'raw_qrtz_paused_trigger_grps') }}