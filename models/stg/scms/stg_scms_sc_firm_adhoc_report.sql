/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_adhoc_report
* Program name: Staging SCMS.SC_FIRM_ADHOC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: event_date, document_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                  AS id
    , CAST(sc_firm_info_id AS bigint)                   AS sc_firm_info_id
    , CAST(attachment_path AS string)                   AS attachment_path
    , CAST(import_file_path AS string)                  AS import_file_path
    , CAST(note AS string)                              AS note
    , CAST(submission_deadline AS timestamp)            AS submission_deadline
    , CAST(cancellation_reason AS string)               AS cancellation_reason
    , CAST(report_year AS bigint)                       AS report_year
    , CAST(last_modified_at AS timestamp)               AS last_modified_at
    , CAST(sent_at AS timestamp)                        AS sent_at
    , CAST(cancelled_at AS timestamp)                   AS cancelled_at
    , CAST(event_date AS date)                     AS event_date
    , CAST(created_at AS timestamp)                     AS created_at
    , CAST(document_date AS date)                  AS document_date
    , CAST(cancelled_by AS bigint)                      AS cancelled_by
    , CAST(summary AS string)                           AS summary
    , CAST(category AS string)                          AS category
    , CAST(late_submission_days AS bigint)              AS late_submission_days
    , CAST(document_number AS string)                   AS document_number
    , CAST(event_type_id AS bigint)                     AS event_type_id
    , CAST(report_name AS string)                       AS report_name
    , CAST(record_status AS bigint)                     AS record_status
    , CAST(signature_type AS string)                    AS signature_type
    , CAST(period_value AS string)                      AS period_value
    , CAST(allow_import AS int)                         AS allow_import
    , CAST(form_report_id AS decimal(19,0))             AS form_report_id
    , CAST(form_version_id AS decimal(19,0))            AS form_version_id
    , CAST(eform_data AS string)                        AS eform_data
    , CAST(import_data_json AS string)                  AS import_data_json
    , CAST(sender_id AS decimal(19,0))                  AS sender_id
    , CAST(requires_disclosure AS int)                  AS requires_disclosure
    , CAST(detail_type AS string)                       AS detail_type
    , CAST(report_input_submission_id AS decimal(19,0)) AS report_input_submission_id
    , CAST(sc_firm_foreign_branch_id AS bigint)         AS sc_firm_foreign_branch_id
    , CAST(bank_id AS bigint)                           AS bank_id
    , CAST(bank_scope AS string)                        AS bank_scope
    , CAST(previous_submit_status AS int)               AS previous_submit_status
FROM {{ source('source_scms', 'raw_sc_firm_adhoc_report') }}