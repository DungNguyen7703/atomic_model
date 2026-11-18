/*
*--------------------------------------------------------------------*
* Program code: stg_iss_input_report_template
* Program name: Staging ISS.INPUT_REPORT_TEMPLATE
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
    , CAST(report_code AS string)                AS report_code
    , CAST(report_name AS string)                 AS report_name
    , CAST(legal_basis AS string)                 AS legal_basis
    , CAST(organization_id AS string)             AS organization_id
    , CAST(effective_from AS timestamp)           AS effective_from
    , CAST(auto_send_to_btc AS int)               AS auto_send_to_btc
    , CAST(description AS string)                 AS description
    , CAST(version AS int)                        AS version
    , CAST(status AS string)                      AS status
    , CAST(report_layout_type AS string)          AS report_layout_type
    , CAST(copy_report_template_id AS string)     AS copy_report_template_id
    , CAST(submit_source_from_icp AS int)         AS submit_source_from_icp
    , CAST(submit_source_from_cdw AS int)         AS submit_source_from_cdw
    , CAST(submit_source_from_kdl AS int)         AS submit_source_from_kdl
    , CAST(template_file_info_id AS string)       AS template_file_info_id
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(deleted AS int)                        AS deleted
FROM {{ source('source_iss', 'raw_input_report_template') }}
