/*
*--------------------------------------------------------------------*
* Program code: stg_tms_case_file_workflow
* Program name: Staging TMS.CASE_FILE_WORKFLOW
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                   AS id
    , CAST(case_file_id AS string)         AS case_file_id
    , CAST(workflow_type AS int)           AS workflow_type
    , CAST(step_order AS int)              AS step_order
    , CAST(step_name AS string)            AS step_name
    , CAST(report_template_id AS string)   AS report_template_id
    , CAST(status AS int)                  AS status
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(updated_at AS timestamp)        AS updated_at
    , CAST(created_by_id AS string)        AS created_by_id
    , CAST(updated_by_id AS string)        AS updated_by_id
    , CAST(created_by_name AS string)      AS created_by_name
    , CAST(updated_by_name AS string)      AS updated_by_name
    , CAST(deleted AS int)                 AS deleted
    , CAST(version AS int)                 AS version
    , CAST(analysis_workflow_id AS string) AS analysis_workflow_id
FROM {{ source('source_tms', 'raw_case_file_workflow') }}