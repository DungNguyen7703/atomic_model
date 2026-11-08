/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_dvcqg_sync_config
* Program name: Staging ECAT.DVCQG_SYNC_CONFIG
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
    , CAST(url_path AS string)                AS url_path
    , CAST(http_method AS string)             AS http_method
    , CAST(status AS int)                     AS status
    , CAST(active_reason AS string)           AS active_reason
    , CAST(display_order AS int)              AS display_order
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(stable_id AS string)               AS stable_id
    , CAST(old_id AS string)                  AS old_id
    , CAST(period_type AS int)                AS period_type
    , CAST(sync_per_time AS bigint)           AS sync_per_time
    , CAST(start_sync_time AS string)         AS start_sync_time
    , CAST(end_sync_time AS string)           AS end_sync_time
FROM {{ source('source_ecat', 'raw_dvcqg_sync_config') }}