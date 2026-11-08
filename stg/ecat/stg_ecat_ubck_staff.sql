/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_ubck_staff
* Program name: Staging ECAT.UBCK_STAFF
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(email AS string)                        AS email
    , CAST(name AS string)                         AS name
    , CAST(personal_identification AS string)      AS personal_identification
    , CAST(phone_number AS string)                 AS phone_number
    , CAST(extension_number AS string)             AS extension_number
    , CAST(department_id AS string)                AS department_id
    , CAST(department_version_id AS string)        AS department_version_id
    , CAST(position_id AS string)                  AS position_id
    , CAST(position_version_id AS string)          AS position_version_id
    , CAST(organization_type_id AS string)         AS organization_type_id
    , CAST(organization_type_version_id AS string) AS organization_type_version_id
    , CAST(active AS int)                          AS active
    , CAST(active_reason AS string)                AS active_reason
    , CAST(deleted AS int)                         AS deleted
    , CAST(deleted_reason AS string)               AS deleted_reason
    , CAST(version AS int)                         AS version
    , CAST(effective_start_date AS timestamp)      AS effective_start_date
    , CAST(effective_end_date AS timestamp)        AS effective_end_date
    , CAST(old_id AS string)                       AS old_id
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(stable_id AS string)                    AS stable_id
FROM {{ source('source_ecat', 'raw_ubck_staff') }}