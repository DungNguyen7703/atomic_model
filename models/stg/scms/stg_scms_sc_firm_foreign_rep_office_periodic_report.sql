/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_rep_office_periodic_report
* Program name: Staging SCMS.SC_FIRM_FOREIGN_REP_OFFICE_PERIODIC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: doi thu tu cot.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (5 cot); doi thu tu cot.
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: event_date, document_date, start_date, end_date; int sang bigint: id, sc_firm_foreign_rep_office_id, event_type_id, cancelled_by.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                            AS id
    , CAST(sc_firm_foreign_rep_office_id AS bigint) AS sc_firm_foreign_rep_office_id
    , CAST(report_name AS string)                AS report_name
    , CAST(report_year AS int)                   AS report_year
    , CAST(period AS int)                        AS period
    , CAST(event_type_id AS bigint)                 AS event_type_id
    , CAST(category AS string)                   AS category
    , CAST(event_date AS date)              AS event_date
    , CAST(summary AS string)                    AS summary
    , CAST(document_number AS string)            AS document_number
    , CAST(document_date AS date)           AS document_date
    , CAST(note AS string)                       AS note
    , CAST(submission_deadline AS timestamp)     AS submission_deadline
    , CAST(sent_at AS timestamp)                 AS sent_at
    , CAST(import_file_path AS string)           AS import_file_path
    , CAST(eform_data AS string)                 AS eform_data
    , CAST(record_status AS int)                 AS record_status
    , CAST(cancellation_reason AS string)        AS cancellation_reason
    , CAST(cancelled_by AS bigint)                  AS cancelled_by
    , CAST(cancelled_at AS timestamp)            AS cancelled_at
    , CAST(start_date AS date)              AS start_date
    , CAST(end_date AS date)                AS end_date
    , CAST(report_period AS string)              AS report_period
    , CAST(quarter AS int)                       AS quarter
    , CAST(report_month AS int)                  AS report_month
    , CAST(submission_deadline_at AS timestamp)  AS submission_deadline_at
    , CAST(attachment_path AS string)            AS attachment_path
    , CAST(previous_submit_status AS int)        AS previous_submit_status
FROM {{ source('source_scms', 'raw_sc_firm_foreign_rep_office_periodic_report') }}