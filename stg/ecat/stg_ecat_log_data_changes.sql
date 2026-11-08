/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_log_data_changes
* Program name: Staging ECAT.LOG_DATA_CHANGES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(application AS string)          AS application
    , CAST(ip_client AS string)            AS ip_client
    , CAST(user_id AS string)              AS user_id
    , CAST(user_name AS string)            AS user_name
    , CAST(full_name AS string)            AS full_name
    , CAST(url AS string)                  AS url
    , CAST(user_agent AS string)           AS user_agent
    , CAST(action_custom AS string)        AS action_custom
    , CAST(filter_custom AS string)        AS filter_custom
    , CAST(action_real AS string)          AS action_real
    , CAST(class_name AS string)           AS class_name
    , CAST(data_change AS string)          AS data_change
    , CAST(created_entity_at AS timestamp) AS created_entity_at
    , CAST(updated_entity_at AS timestamp) AS updated_entity_at
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(updated_at AS timestamp)        AS updated_at
    , CAST(created_by_id AS string)        AS created_by_id
    , CAST(created_by_name AS string)      AS created_by_name
    , CAST(updated_by_id AS string)        AS updated_by_id
    , CAST(updated_by_name AS string)      AS updated_by_name
    , CAST(entity_id AS string)            AS entity_id
    , CAST(entity_name AS string)          AS entity_name
    , CAST(http_method AS string)          AS http_method
FROM {{ source('source_ecat', 'raw_log_data_changes') }}