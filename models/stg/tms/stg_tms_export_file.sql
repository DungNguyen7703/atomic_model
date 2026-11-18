/*
*--------------------------------------------------------------------*
* Program code: stg_tms_export_file
* Program name: Staging TMS.EXPORT_FILE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(file_name AS string)          AS file_name
    , CAST(file_path AS string)          AS file_path
    , CAST(file_length AS decimal(38,0)) AS file_length
    , CAST(status AS string)             AS status
    , CAST(error_message AS string)      AS error_message
    , CAST(execution_details AS string)  AS execution_details
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(created_by_name AS string)    AS created_by_name
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(updated_by_name AS string)    AS updated_by_name
    , CAST(deleted AS int)               AS deleted
    , CAST(created_by_id AS string)      AS created_by_id
    , CAST(updated_by_id AS string)      AS updated_by_id
FROM {{ source('source_tms', 'raw_export_file') }}