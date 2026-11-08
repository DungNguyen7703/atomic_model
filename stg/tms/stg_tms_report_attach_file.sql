/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_attach_file
* Program name: Staging TMS.REPORT_ATTACH_FILE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(report_id AS string)         AS report_id
    , CAST(report_type AS int)          AS report_type
    , CAST(file_category AS int)        AS file_category
    , CAST(file_name AS string)         AS file_name
    , CAST(file_path AS string)         AS file_path
    , CAST(file_size AS decimal(19,0))  AS file_size
    , CAST(file_type AS string)         AS file_type
    , CAST(digital_signature AS string) AS digital_signature
    , CAST(display_order AS int)        AS display_order
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_tms', 'raw_report_attach_file') }}