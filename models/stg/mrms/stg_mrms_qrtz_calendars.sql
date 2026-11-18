/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_calendars
* Program name: Staging MRMS.QRTZ_CALENDARS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)    AS sched_name
    , CAST(calendar_name AS string) AS calendar_name
    , CAST(calendar AS string)      AS calendar
FROM {{ source('source_mrms', 'raw_qrtz_calendars') }}