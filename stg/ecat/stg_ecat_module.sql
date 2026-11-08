/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_module
* Program name: Staging ECAT.MODULE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(code AS string)          AS code
    , CAST(name AS string)          AS name
    , CAST(description AS string)   AS description
    , CAST(status AS int)           AS status
    , CAST(version AS bigint)       AS version
    , CAST(created_at AS timestamp) AS created_at
    , CAST(updated_at AS timestamp) AS updated_at
FROM {{ source('source_ecat', 'raw_module') }}