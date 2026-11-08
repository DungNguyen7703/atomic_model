/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_module_integration_permission
* Program name: Staging ECAT.MODULE_INTEGRATION_PERMISSION
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
    , CAST(permission_id AS string)              AS permission_id
FROM {{ source('source_ecat', 'raw_module_integration_permission') }}