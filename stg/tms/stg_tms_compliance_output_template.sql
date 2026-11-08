/*
*--------------------------------------------------------------------*
* Program code: stg_tms_compliance_output_template
* Program name: Staging TMS.COMPLIANCE_OUTPUT_TEMPLATE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(output_code AS string)         AS output_code
    , CAST(output_name AS string)         AS output_name
    , CAST(output_format AS string)       AS output_format
    , CAST(period_type AS string)         AS period_type
    , CAST(submitter_types AS string)     AS submitter_types
    , CAST(status AS int)                 AS status
    , CAST(table_header_layout AS string) AS table_header_layout
    , CAST(output_config AS string)       AS output_config
    , CAST(word_template_ref AS string)   AS word_template_ref
    , CAST(file_name AS string)           AS file_name
    , CAST(file_path AS string)           AS file_path
    , CAST(file_size AS decimal(38,0))    AS file_size
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(updated_by_name AS string)     AS updated_by_name
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_tms', 'raw_compliance_output_template') }}