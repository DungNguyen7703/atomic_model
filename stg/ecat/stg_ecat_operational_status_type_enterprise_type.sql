/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_operational_status_type_enterprise_type
* Program name: Staging ECAT.OPERATIONAL_STATUS_TYPE_ENTERPRISE_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(operational_status_type_id AS string)  AS operational_status_type_id
    , CAST(enterprise_type_id AS string)        AS enterprise_type_id
    , CAST(enterprise_type_stable_id AS string) AS enterprise_type_stable_id
FROM {{ source('source_ecat', 'raw_operational_status_type_enterprise_type') }}