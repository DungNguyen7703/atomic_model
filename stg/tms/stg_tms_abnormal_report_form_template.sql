/*
*--------------------------------------------------------------------*
* Program code: stg_tms_abnormal_report_form_template
* Program name: Staging TMS.ABNORMAL_REPORT_FORM_TEMPLATE
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
    , CAST(template_id AS string)         AS template_id
    , CAST(form_code AS string)           AS form_code
    , CAST(form_name AS string)           AS form_name
    , CAST(is_mandatory AS int)           AS is_mandatory
    , CAST(display_order AS int)          AS display_order
    , CAST(description AS string)         AS description
    , CAST(table_header_layout AS string) AS table_header_layout
    , CAST(file_name AS string)           AS file_name
    , CAST(file_path AS string)           AS file_path
    , CAST(file_size AS decimal(19,0))    AS file_size
    , CAST(status AS int)                 AS status
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_by_name AS string)     AS updated_by_name
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_tms', 'raw_abnormal_report_form_template') }}