/*
*--------------------------------------------------------------------*
* Program code: stg_fims_user_event_type
* Program name: Staging FIMS.USER_EVENT_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		tuan.nguyenvanb		[MOI] Bo sung STG theo FIMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ssouserid AS string)          AS ssouserid
    , CAST(eventtypeid AS decimal(18,0)) AS eventtypeid
FROM {{ source('source_fims', 'raw_user_event_type') }}