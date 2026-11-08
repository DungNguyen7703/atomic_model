/*
*--------------------------------------------------------------------*
* Program code: stg_iss_input_report_template_sheet
* Program name: Staging ISS.INPUT_REPORT_TEMPLATE_SHEET
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
    , CAST(sheet_name AS string)                  AS sheet_name
    , CAST(sheet_order AS int)                    AS sheet_order
    , CAST(row_start_position AS string)          AS row_start_position
    , CAST(column_start_position AS string)       AS column_start_position
    , CAST(title_position AS string)              AS title_position
    , CAST(time_type AS string)                   AS time_type
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(deleted AS int)                        AS deleted
FROM {{ source('source_iss', 'raw_input_report_template_sheet') }}
