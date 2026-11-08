/*
*--------------------------------------------------------------------*
* Program code: stg_tms_transaction_review_execution_log
* Program name: Staging TMS.TRANSACTION_REVIEW_EXECUTION_LOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(analysis_name AS string)         AS analysis_name
    , CAST(transaction_review_id AS string) AS transaction_review_id
    , CAST(securities_code_id AS string)    AS securities_code_id
    , CAST(securities_code AS string)       AS securities_code
    , CAST(report_template_id AS string)    AS report_template_id
    , CAST(workflow_type AS int)            AS workflow_type
    , CAST(start_time AS timestamp)         AS start_time
    , CAST(end_time AS timestamp)           AS end_time
    , CAST(status AS int)                   AS status
    , CAST(request_param AS string)         AS request_param
    , CAST(error_message AS string)         AS error_message
    , CAST(path AS string)                  AS path
    , CAST(duration_ms AS decimal(19,0))    AS duration_ms
    , CAST(execution_details AS string)     AS execution_details
    , CAST(template_type AS int)            AS template_type
    , CAST(file_name AS string)             AS file_name
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by_id AS string)         AS created_by_id
    , CAST(created_by_name AS string)       AS created_by_name
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(updated_by_id AS string)         AS updated_by_id
    , CAST(updated_by_name AS string)       AS updated_by_name
    , CAST(deleted AS int)                  AS deleted
    , CAST(workflow_id AS string)           AS workflow_id
FROM {{ source('source_tms', 'raw_transaction_review_execution_log') }}