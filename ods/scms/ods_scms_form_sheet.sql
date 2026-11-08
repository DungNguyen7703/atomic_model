/*
*--------------------------------------------------------------------*
* Program code: ods_scms_form_sheet
* Program name: ODS SCMS.FORM_SHEET
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
    , sheet_code
    , sheet_name
    , main_title
    , sub_title
    , cover_page
    , paper_size
    , paper_orientation
    , sort_order
    , note
    , signatory
    , report_style
    , active
    , record_status
    , created_by
    , created_at
    , last_modified_at
    , sub_title_position
    , sub_title_enabled
    , form_sheet_id
    , legacy_sheet_code
    , company_info
    , national_heading
    , rptdetailid
    , sync_column_code
    , record_type
    , columnorder
    , start_row
    , stt_column_code
FROM {{ ref('stg_scms_form_sheet') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')