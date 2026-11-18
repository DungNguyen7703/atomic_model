/*
*--------------------------------------------------------------------*
* Program code: ods_scms_bank_periodic_report
* Program name: ODS SCMS.BANK_PERIODIC_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD SCMS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , form_report_id
    , event_type_id
    , bank_id
    , report_name
    , report_year
    , period
    , report_period
    , quarter
    , report_month
    , start_date
    , end_date
    , submission_deadline
    , record_status
    , import_file_path
    , digital_signature_file
    , valid_digital_signature
    , valid_data
    , sent_at
    , sender_id
    , approved_at
    , approved_by
    , rejection_reason
    , note
    , overdue_days
    , cancelled_at
    , cancelled_by
    , cancellation_reason
    , last_modified_at
    , created_at
    , submission_deadline_at
    , attachment_path
    , previous_submit_status
FROM {{ ref('stg_scms_bank_periodic_report') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')