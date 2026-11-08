/*
*--------------------------------------------------------------------*
* Program code: stg_fms_document
* Program name: Staging FMS.DOCUMENT
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
    , HEX(folder_id)              AS folder_id
    , CAST(item_name AS string)   AS item_name
    , CAST(file_data AS string)   AS file_data
    , CAST(description AS string) AS description
FROM {{ source('source_fms', 'raw_document') }}