/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_module_integration_config
* Program name: Staging ECAT.MODULE_INTEGRATION_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(name AS string)                    AS name
    , CAST(module_id AS string)               AS module_id
    , CAST(client_id AS string)               AS client_id
    , CAST(status AS int)                     AS status
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(deleted AS int)                    AS deleted
    , CAST(version AS int)                    AS version
    , CAST(active_reason AS string)           AS active_reason
    , CAST(stable_id AS string)               AS stable_id
FROM {{ source('source_ecat', 'raw_module_integration_config') }}