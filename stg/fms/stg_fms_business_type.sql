/*
*--------------------------------------------------------------------*
* Program code: stg_fms_business_type
* Program name: Staging FMS.BUSINESS_TYPE
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
    , CAST(record_type AS string) AS record_type
FROM {{ source('source_fms', 'raw_business_type') }}