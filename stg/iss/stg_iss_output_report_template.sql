/*
*--------------------------------------------------------------------*
* Program code: stg_iss_output_report_template
* Program name: Staging ISS.OUTPUT_REPORT_TEMPLATE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(report_code AS string)             AS report_code
    , CAST(report_name AS string)             AS report_name
    , CAST(legal_basis AS string)             AS legal_basis
    , CAST(effective_from AS timestamp)       AS effective_from
    , CAST(auto_send_to_btc AS int)           AS auto_send_to_btc
    , CAST(description AS string)             AS description
    , CAST(version AS int)                    AS version
    , CAST(status AS string)                  AS status
    , CAST(report_layout_type AS string)      AS report_layout_type
    , CAST(copy_report_template_id AS string) AS copy_report_template_id
    , CAST(data_start_row AS string)          AS data_start_row
    , CAST(data_start_column AS string)       AS data_start_column
    , CAST(template_file_info_id AS string)   AS template_file_info_id
    , CAST(report_config AS string)           AS report_config
    , CAST(query_command AS string)           AS query_command
    , CAST(is_data_generation AS int)         AS is_data_generation
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(deleted AS int)                    AS deleted
FROM {{ source('source_iss', 'raw_output_report_template') }}