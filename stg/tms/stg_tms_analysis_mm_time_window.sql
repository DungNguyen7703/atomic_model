/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_mm_time_window
* Program name: Staging TMS.ANALYSIS_MM_TIME_WINDOW
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(case_file_id AS string)                AS case_file_id
    , CAST(workflow_type AS int)                  AS workflow_type
    , CAST(result_type AS int)                    AS result_type
    , CAST(securities_code_id AS string)          AS securities_code_id
    , CAST(securities_code AS string)             AS securities_code
    , CAST(analysis_date AS decimal(19,0))        AS analysis_date
    , CAST(from_time AS decimal(19,0))            AS from_time
    , CAST(to_time AS decimal(19,0))              AS to_time
    , CAST(time_range_display AS string)          AS time_range_display
    , CAST(price_impact_percent AS decimal(15,4)) AS price_impact_percent
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(deleted AS int)                        AS deleted
    , CAST(workflow_id AS string)                 AS workflow_id
FROM {{ source('source_tms', 'raw_analysis_mm_time_window') }}