/*
*--------------------------------------------------------------------*
* Program code: ods_scms_form_report
* Program name: ODS SCMS.FORM_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Dong bo day du cot theo stg moi.
* 2026-10-17		tuan.nguyenvanb		[DONG BO THIET KE MOI - dev khac] them 5 cot (xem stg_scms_form_report).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sys_function_id
    , report_code
    , report_name
    , legal_basis
    , report_group
    , requires_disclosure
    , requires_import
    , attachment_path
    , description
    , active
    , record_status
    , report_type
    , version
    , version_date
    , summary
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , sender_entity
    , form_report_id
    , report_style
    , disclosure_news_type
    , input_report
    , next_form_id
    , legacy_report_type
    , excel_template_path
    , note
    , parent_id
    , signature_type
    , sort_order
    , eform_enabled
    , structure_format
    , primary_source_type
    , identifier_field
    , display_location
    , primary_source_api_id
    , show_grand_total_row
FROM {{ ref('stg_scms_form_report') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')