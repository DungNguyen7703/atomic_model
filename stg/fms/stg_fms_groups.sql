/*
*--------------------------------------------------------------------*
* Program code: stg_fms_groups
* Program name: Staging FMS.GROUPS
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
    , CAST(org_id AS int)         AS org_id
    , CAST(group_name AS string)  AS group_name
    , CAST(record_status AS int)  AS record_status
    , CAST(description AS string) AS description
    , CAST(date_created AS date)  AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS date) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , CAST(deleted AS int)        AS deleted
    , CAST(data_migration AS int) AS data_migration
FROM {{ source('source_fms', 'raw_groups') }}