/*
*--------------------------------------------------------------------*
* Program code: stg_fims_modules
* Program name: Staging FIMS.MODULES
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
    , CAST(service_url AS string)   AS service_url
    , CAST(status AS int)           AS status
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS string)    AS created_by
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(updated_by AS string)    AS updated_by
FROM {{ source('source_fims', 'raw_modules') }}