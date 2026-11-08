/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_organization_type_user_type
* Program name: Staging ECAT.ORGANIZATION_TYPE_USER_TYPE
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
    , CAST(organization_type_id AS string) AS organization_type_id
    , CAST(user_type AS int)               AS user_type
FROM {{ source('source_ecat', 'raw_organization_type_user_type') }}