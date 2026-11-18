/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_periodic_report
* Program name: Staging SCMS.SC_FIRM_PERIODIC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (3 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: start_date, end_date; int sang bigint: event_type_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                   AS id
    , CAST(sc_firm_info_id AS decimal(19,0))    AS sc_firm_info_id
    , CAST(form_report_id AS decimal(19,0))     AS form_report_id
    , CAST(report_name AS string)               AS report_name
    , CAST(report_year AS bigint)               AS report_year
    , CAST(period AS bigint)                    AS period
    , CAST(submission_deadline AS timestamp)    AS submission_deadline
    , CAST(record_status AS bigint)             AS record_status
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(valid_digital_signature AS int)      AS valid_digital_signature
    , CAST(valid_data AS int)                   AS valid_data
    , CAST(digital_signature_file AS string)    AS digital_signature_file
    , CAST(import_file_path AS string)          AS import_file_path
    , CAST(note AS string)                      AS note
    , CAST(report_period AS string)             AS report_period
    , CAST(cancellation_reason AS string)       AS cancellation_reason
    , CAST(rejection_reason AS string)          AS rejection_reason
    , CAST(start_date AS date)             AS start_date
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(approved_at AS timestamp)            AS approved_at
    , CAST(sent_at AS timestamp)                AS sent_at
    , CAST(cancelled_at AS timestamp)           AS cancelled_at
    , CAST(end_date AS date)               AS end_date
    , CAST(approved_by AS bigint)               AS approved_by
    , CAST(sender_id AS bigint)                 AS sender_id
    , CAST(cancelled_by AS bigint)              AS cancelled_by
    , CAST(quarter AS bigint)                   AS quarter
    , CAST(overdue_days AS bigint)              AS overdue_days
    , CAST(report_month AS bigint)              AS report_month
    , CAST(event_type_id AS bigint)                AS event_type_id
    , CAST(summary AS string)                   AS summary
    , CAST(attachment_path AS string)           AS attachment_path
    , CAST(eform_data AS string)                AS eform_data
    , CAST(submission_deadline_at AS timestamp) AS submission_deadline_at
    , CAST(disclosure_eform_data AS string)     AS disclosure_eform_data
    , CAST(import_file_name AS string)          AS import_file_name
    , CAST(previous_submit_status AS int)       AS previous_submit_status
FROM {{ source('source_scms', 'raw_sc_firm_periodic_report') }}