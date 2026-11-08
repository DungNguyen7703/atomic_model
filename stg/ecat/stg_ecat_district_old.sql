/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_district_old
* Program name: Staging ECAT.DISTRICT_OLD
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
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(province_old_id AS string)         AS province_old_id
    , CAST(display_label AS string)           AS display_label
    , CAST(active AS int)                     AS active
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted AS int)                    AS deleted
    , CAST(version AS string)                 AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(stable_id AS string)               AS stable_id
    , CAST(province_old_version_id AS string) AS province_old_version_id
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(effective AS int)                  AS effective
    , CAST(id_sync AS int)                    AS id_sync
FROM {{ source('source_ecat', 'raw_district_old') }}