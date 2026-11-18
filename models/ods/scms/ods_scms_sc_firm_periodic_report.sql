/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_periodic_report
* Program name: ODS SCMS.SC_FIRM_PERIODIC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , form_report_id
    , report_name
    , report_year
    , period
    , submission_deadline
    , record_status
    , created_at
    , valid_digital_signature
    , valid_data
    , digital_signature_file
    , import_file_path
    , note
    , report_period
    , cancellation_reason
    , rejection_reason
    , start_date
    , last_modified_at
    , approved_at
    , sent_at
    , cancelled_at
    , end_date
    , approved_by
    , sender_id
    , cancelled_by
    , quarter
    , overdue_days
    , report_month
    , event_type_id
    , summary
    , attachment_path
    , eform_data
    , submission_deadline_at
    , disclosure_eform_data
    , import_file_name
    , previous_submit_status
FROM {{ ref('stg_scms_sc_firm_periodic_report') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')