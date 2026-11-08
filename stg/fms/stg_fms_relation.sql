/*
*--------------------------------------------------------------------*
* Program code: stg_fms_relation
* Program name: Staging FMS.RELATION
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
    , CAST(item_name AS string)   AS item_name
    , CAST(description AS string) AS description
    , CAST(personal_type AS int)  AS personal_type
    , CAST(record_status AS int)  AS record_status
    , CAST(deleted AS int)        AS deleted
    , CAST(data_migration AS int) AS data_migration
FROM {{ source('source_fms', 'raw_relation') }}