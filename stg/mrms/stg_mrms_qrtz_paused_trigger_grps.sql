/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_paused_trigger_grps
* Program name: Staging MRMS.QRTZ_PAUSED_TRIGGER_GRPS
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
    , CAST(trigger_group AS string) AS trigger_group
FROM {{ source('source_mrms', 'raw_qrtz_paused_trigger_grps') }}