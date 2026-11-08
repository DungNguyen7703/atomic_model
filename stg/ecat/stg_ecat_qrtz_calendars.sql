/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_calendars
* Program name: Staging ECAT.QRTZ_CALENDARS
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
    , CAST(calendar_name AS string) AS calendar_name
    , CAST(calendar AS string)      AS calendar
FROM {{ source('source_ecat', 'raw_qrtz_calendars') }}