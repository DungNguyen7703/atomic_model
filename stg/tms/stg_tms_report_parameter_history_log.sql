/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_parameter_history_log
* Program name: Staging TMS.REPORT_PARAMETER_HISTORY_LOG
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
    , CAST(report_parameter_id AS string) AS report_parameter_id
    , CAST(action_type AS int)            AS action_type
    , CAST(action_status AS int)          AS action_status
    , CAST(action_reason AS string)       AS action_reason
    , CAST(action_at AS timestamp)        AS action_at
    , CAST(deleted AS int)                AS deleted
    , CAST(action_by_id AS string)        AS action_by_id
    , CAST(before_data AS string)         AS before_data
    , CAST(after_data AS string)          AS after_data
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_by_name AS string)     AS updated_by_name
FROM {{ source('source_tms', 'raw_report_parameter_history_log') }}