/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_event_type_status_link
* Program name: Staging FIMS.RPT_EVENT_TYPE_STATUS_LINK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(rpt_event_type_id AS bigint) AS rpt_event_type_id
    , CAST(status_id AS bigint)       AS status_id
FROM {{ source('source_fims', 'raw_rpt_event_type_status_link') }}