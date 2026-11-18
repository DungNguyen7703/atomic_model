/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_workflow
* Program name: Staging TMS.ANALYSIS_WORKFLOW
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
    , CAST(workflow_name AS string)      AS workflow_name
    , CAST(base_workflow_type AS int)    AS base_workflow_type
    , CAST(source_workflow_id AS string) AS source_workflow_id
    , CAST(workflow_category AS int)     AS workflow_category
    , CAST(status AS int)                AS status
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(created_by_id AS string)      AS created_by_id
    , CAST(updated_by_id AS string)      AS updated_by_id
    , CAST(created_by_name AS string)    AS created_by_name
    , CAST(updated_by_name AS string)    AS updated_by_name
    , CAST(deleted AS int)               AS deleted
FROM {{ source('source_tms', 'raw_analysis_workflow') }}