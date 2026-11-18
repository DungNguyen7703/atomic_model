/*
*--------------------------------------------------------------------*
* Program code: stg_iss_input_report
* Program name: Staging ISS.INPUT_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-09-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(input_report_template_id AS string)    AS input_report_template_id
    , CAST(input_report_deadline_id AS string)    AS input_report_deadline_id
    , CAST(organization_id AS string)             AS organization_id
    , CAST(period_type AS string)                 AS period_type
    , CAST(report_obligation_type AS string)      AS report_obligation_type
    , CAST(period_value AS string)                AS period_value
    , CAST(period_date AS date)                   AS period_date
    , CAST(report_year AS int)                    AS report_year
    , CAST(report_due_time AS timestamp)          AS report_due_time
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(deleted AS int)                        AS deleted
FROM {{ source('source_iss', 'raw_input_report') }}
