/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_practice_certificate
* Program name: Staging ECAT.PRACTICE_CERTIFICATE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(name AS string)            AS name
    , CAST(active AS int)             AS active
    , CAST(deleted AS int)            AS deleted
    , CAST(version AS int)            AS version
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
FROM {{ source('source_ecat', 'raw_practice_certificate') }}