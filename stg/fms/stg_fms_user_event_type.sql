/*
*--------------------------------------------------------------------*
* Program code: stg_fms_user_event_type
* Program name: Staging FMS.USER_EVENT_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(user_id)       AS user_id
    , HEX(event_type_id) AS event_type_id
FROM {{ source('source_fms', 'raw_user_event_type') }}