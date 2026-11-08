/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_report
* Program name: Staging SCMS.FORM_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (3 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: version_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                             AS id
    , CAST(sys_function_id AS bigint)              AS sys_function_id
    , CAST(report_code AS string)                  AS report_code
    , CAST(report_name AS string)                  AS report_name
    , CAST(legal_basis AS string)                  AS legal_basis
    , CAST(report_group AS string)                 AS report_group
    , CAST(requires_disclosure AS int)             AS requires_disclosure
    , CAST(requires_import AS int)                 AS requires_import
    , CAST(attachment_path AS string)              AS attachment_path
    , CAST(description AS string)                  AS description
    , CAST(active AS int)                          AS active
    , CAST(record_status AS int)                   AS record_status
    , CAST(report_type AS string)                  AS report_type
    , CAST(version AS int)                         AS version
    , CAST(version_date AS date)              AS version_date
    , CAST(summary AS int)                         AS summary
    , CAST(created_by AS bigint)                   AS created_by
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(last_modified_by AS bigint)             AS last_modified_by
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(sender_entity AS string)                AS sender_entity
    , CAST(form_report_id AS bigint)               AS form_report_id
    , CAST(report_style AS int)                    AS report_style
    , CAST(disclosure_news_type AS string)         AS disclosure_news_type
    , CAST(input_report AS int)                    AS input_report
    , CAST(next_form_id AS bigint)                 AS next_form_id
    , CAST(legacy_report_type AS string)           AS legacy_report_type
    , CAST(excel_template_path AS string)          AS excel_template_path
    , CAST(note AS string)                         AS note
    , CAST(parent_id AS bigint)                    AS parent_id
    , CAST(signature_type AS bigint)               AS signature_type
    , CAST(sort_order AS bigint)                   AS sort_order
    , CAST(eform_enabled AS int)                   AS eform_enabled
    , CAST(structure_format AS string)             AS structure_format
    , CAST(primary_source_type AS string)          AS primary_source_type
    , CAST(identifier_field AS string)             AS identifier_field
    , CAST(display_location AS string)             AS display_location
    , CAST(primary_source_api_id AS decimal(19,0)) AS primary_source_api_id
    , CAST(show_grand_total_row AS int)            AS show_grand_total_row
FROM {{ source('source_scms', 'raw_form_report') }}