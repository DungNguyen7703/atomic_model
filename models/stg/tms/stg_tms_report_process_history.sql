/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_process_history
* Program name: Staging TMS.REPORT_PROCESS_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(report_id AS string)        AS report_id
    , CAST(report_type AS int)         AS report_type
    , CAST(action_type AS int)         AS action_type
    , CAST(action_by_id AS string)     AS action_by_id
    , CAST(action_by_name AS string)   AS action_by_name
    , CAST(action_by_title AS string)  AS action_by_title
    , CAST(action_date AS timestamp)   AS action_date
    , CAST(action_result AS string)    AS action_result
    , CAST(reason AS string)           AS reason
    , CAST(resubmit_from_date AS date) AS resubmit_from_date
    , CAST(resubmit_to_date AS date)   AS resubmit_to_date
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_tms', 'raw_report_process_history') }}