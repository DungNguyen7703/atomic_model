/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_adhoc_report
* Program name: ODS SCMS.SC_FIRM_ADHOC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Doi ten cot theo stg moi (SCMS_UAT_schema).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , attachment_path
    , import_file_path
    , note
    , submission_deadline
    , cancellation_reason
    , report_year
    , last_modified_at
    , sent_at
    , cancelled_at
    , event_date
    , created_at
    , document_date
    , cancelled_by
    , summary
    , category
    , late_submission_days
    , document_number
    , event_type_id
    , report_name
    , record_status
    , signature_type
    , period_value
    , allow_import
    , form_report_id
    , form_version_id
    , eform_data
    , import_data_json
    , sender_id
    , requires_disclosure
    , detail_type
    , report_input_submission_id
    , sc_firm_foreign_branch_id
    , bank_id
    , bank_scope
    , previous_submit_status
FROM {{ ref('stg_scms_sc_firm_adhoc_report') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')