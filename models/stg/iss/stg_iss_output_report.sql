/*
*--------------------------------------------------------------------*
* Program code: stg_iss_output_report
* Program name: Staging ISS.OUTPUT_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(output_report_template_id AS string) AS output_report_template_id
    , CAST(period_type AS string)               AS period_type
    , CAST(period_value AS string)              AS period_value
    , CAST(period_date AS date)                 AS period_date
    , CAST(period_end_date AS date)             AS period_end_date
    , CAST(status AS string)                    AS status
    , CAST(note AS string)                      AS note
    , CAST(file_info_id AS string)              AS file_info_id
    , CAST(created_by_id AS string)             AS created_by_id
    , CAST(created_by_name AS string)           AS created_by_name
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(updated_by_id AS string)             AS updated_by_id
    , CAST(updated_by_name AS string)           AS updated_by_name
    , CAST(updated_at AS timestamp)             AS updated_at
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_iss', 'raw_output_report') }}