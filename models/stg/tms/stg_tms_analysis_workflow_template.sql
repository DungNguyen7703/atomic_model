/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_workflow_template
* Program name: Staging TMS.ANALYSIS_WORKFLOW_TEMPLATE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(workflow_id AS string)        AS workflow_id
    , CAST(report_template_id AS string) AS report_template_id
    , CAST(parameters AS string)         AS parameters
    , CAST(display_order AS int)         AS display_order
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(created_by_id AS string)      AS created_by_id
    , CAST(updated_by_id AS string)      AS updated_by_id
    , CAST(created_by_name AS string)    AS created_by_name
    , CAST(updated_by_name AS string)    AS updated_by_name
    , CAST(deleted AS int)               AS deleted
    , CAST(template_role AS int)         AS template_role
    , CAST(report_type AS int)           AS report_type
FROM {{ source('source_tms', 'raw_analysis_workflow_template') }}