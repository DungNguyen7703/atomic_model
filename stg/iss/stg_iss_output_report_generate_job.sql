/*
*--------------------------------------------------------------------*
* Program code: stg_iss_output_report_generate_job
* Program name: Staging ISS.OUTPUT_REPORT_GENERATE_JOB
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(status AS string)          AS status
    , CAST(owner_node AS string)      AS owner_node
    , CAST(error_message AS string)   AS error_message
    , CAST(attempts AS int)           AS attempts
    , CAST(max_attempts AS int)       AS max_attempts
    , CAST(scheduled_at AS timestamp) AS scheduled_at
    , CAST(started_at AS timestamp)   AS started_at
    , CAST(completed_at AS timestamp) AS completed_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_iss', 'raw_output_report_generate_job') }}