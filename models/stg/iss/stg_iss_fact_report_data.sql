/*
*--------------------------------------------------------------------*
* Program code: stg_iss_fact_report_data
* Program name: Staging ISS.FACT_REPORT_DATA
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
    , CAST(input_report_submission_id AS string)  AS input_report_submission_id
    , CAST(sheet_id AS string)                    AS sheet_id
    , CAST(date_type AS string)                   AS date_type
    , CAST(origin_date_value AS string)           AS origin_date_value
    , CAST(day AS int)                            AS day
    , CAST(month AS int)                          AS month
    , CAST(quarter AS int)                        AS quarter
    , CAST(half_year AS int)                       AS half_year
    , CAST(year AS int)                           AS year
    , CAST(json_data AS string)                   AS json_data
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(deleted AS int)                        AS deleted
    , CAST(data_index AS bigint)                  AS data_index
FROM {{ source('source_iss', 'raw_fact_report_data') }}
