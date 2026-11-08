/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_organization_type
* Program name: Staging ECAT.ORGANIZATION_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)           AS id
    , CAST(code AS string)       AS code
    , CAST(name AS string)       AS name
    , CAST(user_type AS int)     AS user_type
    , CAST(user_group AS string) AS user_group
FROM {{ source('source_ecat', 'raw_organization_type') }}