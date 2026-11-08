/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_module_integration_resource
* Program name: Staging ECAT.MODULE_INTEGRATION_RESOURCE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(module_integration_config_id AS string) AS module_integration_config_id
    , CAST(resource_id AS string)                AS resource_id
    , CAST(resource_code AS string)              AS resource_code
    , CAST(active AS int)                        AS active
    , CAST(active_reason AS string)              AS active_reason
FROM {{ source('source_ecat', 'raw_module_integration_resource') }}