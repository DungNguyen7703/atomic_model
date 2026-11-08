/*
*--------------------------------------------------------------------*
* Program code: stg_tms_document_outgoing
* Program name: Staging TMS.DOCUMENT_OUTGOING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(template_id AS string)             AS template_id
    , CAST(name AS string)                    AS name
    , CAST(input_data AS string)              AS input_data
    , CAST(excel_file_name AS string)         AS excel_file_name
    , CAST(excel_file_path AS string)         AS excel_file_path
    , CAST(excel_file_size AS decimal(19,0))  AS excel_file_size
    , CAST(output_kind AS int)                AS output_kind
    , CAST(output_file_name AS string)        AS output_file_name
    , CAST(output_file_path AS string)        AS output_file_path
    , CAST(output_file_size AS decimal(19,0)) AS output_file_size
    , CAST(output_file_type AS string)        AS output_file_type
    , CAST(generated_count AS int)            AS generated_count
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(deleted AS int)                    AS deleted
FROM {{ source('source_tms', 'raw_document_outgoing') }}