/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_foreign_rep_office_periodic_report
* Program name: ODS SCMS.SC_FIRM_FOREIGN_REP_OFFICE_PERIODIC_REPORT
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
    , sc_firm_foreign_rep_office_id
    , report_name
    , report_year
    , period
    , event_type_id
    , category
    , event_date
    , summary
    , document_number
    , document_date
    , note
    , submission_deadline
    , sent_at
    , import_file_path
    , eform_data
    , record_status
    , cancellation_reason
    , cancelled_by
    , cancelled_at
    , start_date
    , end_date
    , report_period
    , quarter
    , report_month
    , submission_deadline_at
    , attachment_path
    , previous_submit_status
FROM {{ ref('stg_scms_sc_firm_foreign_rep_office_periodic_report') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')