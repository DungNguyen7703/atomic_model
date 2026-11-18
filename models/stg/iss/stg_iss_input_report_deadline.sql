/*
*--------------------------------------------------------------------*
* Program code: stg_iss_input_report_deadline
* Program name: Staging ISS.INPUT_REPORT_DEADLINE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(input_report_template_id AS string) AS input_report_template_id
    , CAST(reporting_period AS string)         AS reporting_period
    , CAST(due_date AS int)                    AS due_date
    , CAST(due_date_unit AS string)            AS due_date_unit
    , CAST(reminder_before AS int)             AS reminder_before
    , CAST(reminder_period AS string)          AS reminder_period
    , CAST(period_indices AS string)           AS period_indices
    , CAST(exclude_holiday AS int)             AS exclude_holiday
    , CAST(last_generate_at AS timestamp)      AS last_generate_at
    , CAST(next_generate_at AS timestamp)      AS next_generate_at
    , CAST(error_count AS int)                 AS error_count
    , CAST(last_error_message AS string)       AS last_error_message
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(deleted AS int)                     AS deleted
FROM {{ source('source_iss', 'raw_input_report_deadline') }}