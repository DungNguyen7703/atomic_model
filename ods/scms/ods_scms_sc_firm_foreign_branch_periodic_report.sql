/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_foreign_branch_periodic_report
* Program name: ODS SCMS.SC_FIRM_FOREIGN_BRANCH_PERIODIC_REPORT
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
    , sc_firm_foreign_branch_id
    , eform_data
    , import_file_path
    , submission_deadline
    , period
    , cancellation_reason
    , report_year
    , sent_at
    , cancelled_at
    , cancelled_by
    , report_name
    , record_status
    , event_type_id
    , category
    , event_date
    , summary
    , document_number
    , document_date
    , note
    , start_date
    , end_date
    , report_period
    , quarter
    , report_month
    , submission_deadline_at
    , attachment_path
    , previous_submit_status
FROM {{ ref('stg_scms_sc_firm_foreign_branch_periodic_report') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')