/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_report
* Program name: Staging TMS.ANALYSIS_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(case_file_id AS string)              AS case_file_id
    , CAST(report_type AS string)               AS report_type
    , CAST(report_file_path AS string)          AS report_file_path
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(updated_at AS timestamp)             AS updated_at
    , CAST(created_by_id AS string)             AS created_by_id
    , CAST(updated_by_id AS string)             AS updated_by_id
    , CAST(created_by_name AS string)           AS created_by_name
    , CAST(updated_by_name AS string)           AS updated_by_name
    , CAST(version AS int)                      AS version
    , CAST(deleted AS int)                      AS deleted
    , CAST(status AS string)                    AS status
    , CAST(report_result_analysis AS string)    AS report_result_analysis
    , CAST(start_time AS timestamp)             AS start_time
    , CAST(report_name AS string)               AS report_name
    , CAST(analysis_date AS timestamp)          AS analysis_date
    , CAST(result_type AS string)               AS result_type
    , CAST(workflow_type AS string)             AS workflow_type
    , CAST(securities_code_id AS string)        AS securities_code_id
    , CAST(securities_code AS string)           AS securities_code
    , CAST(workflow_id AS string)               AS workflow_id
    , CAST(template_type AS int)                AS template_type
    , CAST(analysis_execution_log_id AS string) AS analysis_execution_log_id
FROM {{ source('source_tms', 'raw_analysis_report') }}