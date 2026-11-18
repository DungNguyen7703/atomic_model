/*
*--------------------------------------------------------------------*
* Program code: stg_iss_output_report_metric
* Program name: Staging ISS.OUTPUT_REPORT_METRIC
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
    , CAST(parent_id AS string)                 AS parent_id
    , CAST(order_in_level AS int)               AS order_in_level
    , CAST(node_name AS string)                 AS node_name
    , CAST(position AS string)                  AS position
    , CAST(is_data_generation AS int)           AS is_data_generation
    , CAST(format AS string)                    AS format
    , CAST(date_type AS string)                 AS date_type
    , CAST(metric_code AS string)               AS metric_code
    , CAST(description AS string)               AS description
    , CAST(metric_type AS string)               AS metric_type
    , CAST(created_by_id AS string)             AS created_by_id
    , CAST(created_by_name AS string)           AS created_by_name
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(updated_by_id AS string)             AS updated_by_id
    , CAST(updated_by_name AS string)           AS updated_by_name
    , CAST(updated_at AS timestamp)             AS updated_at
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_iss', 'raw_output_report_metric') }}