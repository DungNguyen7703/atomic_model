/*
*--------------------------------------------------------------------*
* Program code: stg_fms_event_type_agency_type
* Program name: Staging FMS.EVENT_TYPE_AGENCY_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)               AS id
    , HEX(event_type_id)  AS event_type_id
    , HEX(agency_type_id) AS agency_type_id
FROM {{ source('source_fms', 'raw_event_type_agency_type') }}