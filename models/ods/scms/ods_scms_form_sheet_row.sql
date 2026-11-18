/*
*--------------------------------------------------------------------*
* Program code: ods_scms_form_sheet_row
* Program name: ODS SCMS.FORM_SHEET_ROW
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
    , form_sheet_id
    , row_code
    , row_name
    , sort_order
    , name_format
    , color
    , alignment
    , frozen_row
    , description
    , active
    , record_status
    , version
    , last_modified_at_legacy
    , legacy_row_code
    , sync_row_code
    , hidden_row
    , hierarchy_level
    , editable
    , formula
    , parent_row_id
    , bold
    , italic
    , row_type
    , background_color
    , last_modified_at
    , created_at
    , last_modified_by
    , created_by
FROM {{ ref('stg_scms_form_sheet_row') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')