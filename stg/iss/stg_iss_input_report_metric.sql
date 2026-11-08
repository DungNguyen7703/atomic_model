/*
*--------------------------------------------------------------------*
* Program code: stg_iss_input_report_metric
* Program name: Staging ISS.INPUT_REPORT_METRIC
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
    , CAST(sheet_id AS string)                    AS sheet_id
    , CAST(parent_id AS string)                   AS parent_id
    , CAST(order_in_level AS int)                 AS order_in_level
    , CAST(node_name AS string)                   AS node_name
    , CAST(metric_code AS string)                 AS metric_code
    , CAST(is_dimension AS int)                   AS is_dimension
    , CAST(is_have_data AS int)                   AS is_have_data
    , CAST(position AS string)                    AS position
    , CAST(unit AS string)                        AS unit
    , CAST(description AS string)                 AS description
    , CAST(data_type AS string)                   AS data_type
    , CAST(metric_type AS string)                 AS metric_type
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(deleted AS int)                        AS deleted
FROM {{ source('source_iss', 'raw_input_report_metric') }}
