/*
*--------------------------------------------------------------------*
* Program code: stg_scms_member_report
* Program name: Staging SCMS.MEMBER_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (12 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (4 cot); kieu string sang binary (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: data_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(sc_firm_info_id AS bigint)           AS sc_firm_info_id
    , CAST(user_id AS bigint)                   AS user_id
    , CAST(form_report_id AS bigint)            AS form_report_id
    , CAST(form_periodic_report_id AS bigint)   AS form_periodic_report_id
    , CAST(description AS string)               AS description
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(submission_deadline_at AS timestamp) AS submission_deadline_at
    , CAST(extension_deadline_at AS timestamp)  AS extension_deadline_at
    , CAST(submission_time AS string)           AS submission_time
    , CAST(reason AS string)                    AS reason
    , CAST(resubmission_reason AS string)       AS resubmission_reason
    , CAST(attachment_path AS string)           AS attachment_path
    , CAST(data_date AS date)              AS data_date
    , CAST(deleted AS int)                      AS deleted
    , CAST(sent_at AS timestamp)                AS sent_at
    , CAST(record_status AS int)                AS record_status
    , CAST(version AS int)                      AS version
    , CAST(audit_firm_id AS bigint)             AS audit_firm_id
    , CAST(auditor_id AS bigint)                AS auditor_id
    , CAST(alert_year AS string)                AS alert_year
    , CAST(report_period AS string)             AS report_period
    , CAST(report_period_value AS string)       AS report_period_value
    , CAST(summary AS string)                   AS summary
    , CAST(deleted_at AS timestamp)             AS deleted_at
    , CAST(report_locked AS int)                AS report_locked
    , CAST(audit_status AS string)              AS audit_status
    , CAST(submission_report_type AS string)    AS submission_report_type
    , CAST(report_cancelled AS int)             AS report_cancelled
    , CAST(report_name AS string)               AS report_name
    , CAST(note AS string)                      AS note
    , CAST(extension_reason AS string)          AS extension_reason
    , CAST(report_file_path AS string)          AS report_file_path
    , CAST(valid_report_submission AS int)      AS valid_report_submission
    , CAST(legacy_rowtext AS string)            AS legacy_rowtext
    , CAST(converted AS int)                    AS converted
    , CAST(legacy_log_id AS string)             AS legacy_log_id
    , CAST(legacy_filename AS string)           AS legacy_filename
    , CAST(legacy_filedata AS binary)           AS legacy_filedata
    , CAST(period AS bigint)                    AS period
    , CAST(report_year AS bigint)               AS report_year
    , CAST(approved_at AS timestamp)            AS approved_at
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(approved_by AS bigint)               AS approved_by
    , CAST(last_modified_by AS bigint)          AS last_modified_by
    , CAST(created_by AS bigint)                AS created_by
    , CAST(event_type_id AS decimal(19,0))      AS event_type_id
FROM {{ source('source_scms', 'raw_member_report') }}