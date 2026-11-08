/*
*--------------------------------------------------------------------*
* Program code: stg_tms_abnormal_report_form
* Program name: Staging TMS.ABNORMAL_REPORT_FORM
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
    , CAST(report_id AS string)           AS report_id
    , CAST(form_template_id AS string)    AS form_template_id
    , CAST(attach_file_id AS string)      AS attach_file_id
    , CAST(submission_no AS int)          AS submission_no
    , CAST(file_name AS string)           AS file_name
    , CAST(file_path AS string)           AS file_path
    , CAST(file_size AS decimal(19,0))    AS file_size
    , CAST(file_type AS string)           AS file_type
    , CAST(upload_date AS timestamp)      AS upload_date
    , CAST(validation_status AS int)      AS validation_status
    , CAST(validation_errors AS string)   AS validation_errors
    , CAST(total_rows AS int)             AS total_rows
    , CAST(is_current AS int)             AS is_current
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_by_name AS string)     AS updated_by_name
    , CAST(deleted AS int)                AS deleted
    , CAST(table_header_layout AS string) AS table_header_layout
FROM {{ source('source_tms', 'raw_abnormal_report_form') }}