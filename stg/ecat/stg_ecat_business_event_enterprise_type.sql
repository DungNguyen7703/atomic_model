/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_business_event_enterprise_type
* Program name: Staging ECAT.BUSINESS_EVENT_ENTERPRISE_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(business_event_id AS string)           AS business_event_id
    , CAST(enterprise_type_id AS string)        AS enterprise_type_id
    , CAST(business_event_stable_id AS string)  AS business_event_stable_id
    , CAST(enterprise_type_stable_id AS string) AS enterprise_type_stable_id
FROM {{ source('source_ecat', 'raw_business_event_enterprise_type') }}