/*
*--------------------------------------------------------------------*
* Program code: atm_internal_statistical_report
* Program name: Atomic Internal Statistical Report
* Created by: huy.pham
* Created date: 2026-10-08
*--------------------------------------------------------------------*
* Modified management
* Date            User        Description
* 2026-10-08      Hoang       Tao moi. Source: ods_iss_flat_report.
*                             Materialization: upsert (Classification).
*                             BK: report_code|sheet_name|field_code|row_num|origin_date_value
* 2026-10-23      nghia.le    Doi ten cot output khop DataModel
*                             dm_atm_internal_statistical_report-ISS.INTERNAL_STATISTICAL_REPORT.yaml.
*                             Xoa cot thua template_status_code (khong co trong DataModel).
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        report_code
        , report_name
        , submit_source
        , template_version
        , template_status
        , report_layout_type
        , sheet_name
        , row_start_position
        , column_start_position
        , row_num
        , data_type
        , col_position
        , column_path
        , row_position
        , row_path
        , column_code
        , row_code
        , field_code
        , field_value
        , date_type
        , origin_date_value
        , report_day
        , report_month
        , report_quarter
        , report_half_year
        , report_year
        , submit_status
    FROM {{ ref('ods_iss_flat_report') }}
)

SELECT
    {{ generate_surrogate_key(
        'ISS_INTERNAL_STATISTICAL_REPORT',
        "concat_ws('-', report_code, sheet_name, field_code, CAST(row_num AS string), origin_date_value)"
    ) }}                                                                    AS internal_statistical_rpt_id
    , concat_ws('-', report_code, sheet_name, field_code, CAST(row_num AS string), origin_date_value) AS internal_statistical_rpt_code
    , CAST('ISS_INTERNAL_STATISTICAL_REPORT' AS string)                                     AS src_stm_code
    , CAST(report_code AS string)                                            AS rpt_code
    , CAST(report_name AS string)                                            AS rpt_nm
    , CAST(submit_source AS string)                                          AS rpt_submission_stm_code
    , CAST(template_version AS int)                                          AS version_nbr
    , CAST(report_layout_type AS string)                                     AS rpt_tp_code
    , CAST(sheet_name AS string)                                             AS sheet_nm
    , CAST(column_start_position AS string)                                  AS column_start_adr
    , CAST(row_start_position AS string)                                     AS row_start_adr
    , CAST(column_path AS string)                                            AS column_path
    , CAST(row_path AS string)                                               AS row_path
    , CAST(row_num AS int)                                                   AS row_index
    , CAST(col_position AS string)                                           AS column_adr
    , CAST(row_position AS string)                                           AS row_adr
    , CAST(column_code AS string)                                            AS column_code
    , CAST(row_code AS string)                                               AS row_code
    , CAST(field_code AS string)                                             AS cell_code
    , CAST(data_type AS string)                                              AS data_tp_code
    , CAST(field_value AS string)                                            AS cell_val
    , CAST(date_type AS string)                                              AS period_tp_code
    , CAST(origin_date_value AS string)                                      AS period_val
    , CAST(report_day AS int)                                                AS rpt_day
    , CAST(report_month AS int)                                              AS rpt_month
    , CAST(report_quarter AS int)                                            AS rpt_quarter
    , CAST(report_half_year AS int)                                          AS rpt_half_year
    , CAST(report_year AS int)                                               AS rpt_year
    , CAST(submit_status AS string)                                          AS submission_status_code
FROM src
