/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_workflow_history_log
* Program name: Staging TMS.ANALYSIS_WORKFLOW_HISTORY_LOG
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
    , CAST(analysis_workflow_id AS string) AS analysis_workflow_id
    , CAST(action_type AS int)             AS action_type
    , CAST(action_reason AS string)        AS action_reason
    , CAST(before_data AS string)          AS before_data
    , CAST(after_data AS string)           AS after_data
    , CAST(action_at AS timestamp)         AS action_at
    , CAST(action_by_id AS string)         AS action_by_id
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(updated_at AS timestamp)        AS updated_at
    , CAST(created_by_id AS string)        AS created_by_id
    , CAST(updated_by_id AS string)        AS updated_by_id
    , CAST(created_by_name AS string)      AS created_by_name
    , CAST(updated_by_name AS string)      AS updated_by_name
    , CAST(deleted AS int)                 AS deleted
FROM {{ source('source_tms', 'raw_analysis_workflow_history_log') }}