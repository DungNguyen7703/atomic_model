/*
*--------------------------------------------------------------------*
* Program code: stg_scms_bank_periodic_report
* Program name: Staging SCMS.BANK_PERIODIC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (3 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: start_date, end_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                 AS id
    , CAST(form_report_id AS decimal(19,0))     AS form_report_id
    , CAST(event_type_id AS decimal(19,0))      AS event_type_id
    , CAST(bank_id AS decimal(19,0))            AS bank_id
    , CAST(report_name AS string)               AS report_name
    , CAST(report_year AS bigint)               AS report_year
    , CAST(period AS bigint)                    AS period
    , CAST(report_period AS string)             AS report_period
    , CAST(quarter AS bigint)                   AS quarter
    , CAST(report_month AS bigint)              AS report_month
    , CAST(start_date AS date)             AS start_date
    , CAST(end_date AS date)               AS end_date
    , CAST(submission_deadline AS timestamp)    AS submission_deadline
    , CAST(record_status AS bigint)             AS record_status
    , CAST(import_file_path AS string)          AS import_file_path
    , CAST(digital_signature_file AS string)    AS digital_signature_file
    , CAST(valid_digital_signature AS int)      AS valid_digital_signature
    , CAST(valid_data AS int)                   AS valid_data
    , CAST(sent_at AS timestamp)                AS sent_at
    , CAST(sender_id AS decimal(19,0))          AS sender_id
    , CAST(approved_at AS timestamp)            AS approved_at
    , CAST(approved_by AS decimal(19,0))        AS approved_by
    , CAST(rejection_reason AS string)          AS rejection_reason
    , CAST(note AS string)                      AS note
    , CAST(overdue_days AS bigint)              AS overdue_days
    , CAST(cancelled_at AS timestamp)           AS cancelled_at
    , CAST(cancelled_by AS decimal(19,0))       AS cancelled_by
    , CAST(cancellation_reason AS string)       AS cancellation_reason
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(submission_deadline_at AS timestamp) AS submission_deadline_at
    , CAST(attachment_path AS string)           AS attachment_path
    , CAST(previous_submit_status AS int)       AS previous_submit_status
FROM {{ source('source_scms', 'raw_bank_periodic_report') }}