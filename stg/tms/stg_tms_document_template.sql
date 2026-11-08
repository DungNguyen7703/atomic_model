/*
*--------------------------------------------------------------------*
* Program code: stg_tms_document_template
* Program name: Staging TMS.DOCUMENT_TEMPLATE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(template_name AS string)    AS template_name
    , CAST(file_name AS string)        AS file_name
    , CAST(file_path AS string)        AS file_path
    , CAST(file_size AS decimal(19,0)) AS file_size
    , CAST(file_type AS string)        AS file_type
    , CAST(status AS int)              AS status
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
    , CAST(placeholders AS string)     AS placeholders
FROM {{ source('source_tms', 'raw_document_template') }}