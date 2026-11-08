/*
*--------------------------------------------------------------------*
* Program code: stg_fms_roles
* Program name: Staging FMS.ROLES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(date_created AS date)  AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS date) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , CAST(role_name AS string)   AS role_name
    , CAST(description AS string) AS description
    , CAST(record_status AS int)  AS record_status
    , CAST(deleted AS int)        AS deleted
FROM {{ source('source_fms', 'raw_roles') }}