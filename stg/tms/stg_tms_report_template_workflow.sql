/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_template_workflow
* Program name: Staging TMS.REPORT_TEMPLATE_WORKFLOW
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(template_id AS string)     AS template_id
    , CAST(workflow_type AS int)      AS workflow_type
    , CAST(essential AS int)          AS essential
    , CAST(report_type AS int)        AS report_type
    , CAST(parameters AS string)      AS parameters
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
    , CAST(template_type AS int)      AS template_type
    , CAST(case_file_id AS string)    AS case_file_id
    , CAST(securities_id AS string)   AS securities_id
    , CAST(securities_code AS string) AS securities_code
FROM {{ source('source_tms', 'raw_report_template_workflow') }}