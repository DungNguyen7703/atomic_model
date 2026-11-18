/*
*--------------------------------------------------------------------*
* Program code: stg_fms_distributor_location
* Program name: Staging FMS.DISTRIBUTOR_LOCATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                               AS id
    , HEX(distributor_agent_id)           AS distributor_agent_id
    , CAST(item_name AS string)           AS item_name
    , CAST(address AS string)             AS address
    , CAST(phone AS string)               AS phone
    , CAST(record_status AS int)          AS record_status
    , CAST(deleted AS int)                AS deleted
    , CAST(date_created AS timestamp)     AS date_created
    , CAST(created_by AS string)          AS created_by
    , CAST(date_modified AS timestamp)    AS date_modified
    , CAST(modify_by AS string)           AS modify_by
    , CAST(business_license_no AS string) AS business_license_no
    , CAST(fax AS string)                 AS fax
FROM {{ source('source_fms', 'raw_distributor_location') }}