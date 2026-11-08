/*
*--------------------------------------------------------------------*
* Program code: ods_scms_form_sheet_column
* Program name: ODS SCMS.FORM_SHEET_COLUMN
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
    , column_code
    , column_name
    , sort_order
    , name_format
    , color
    , alignment
    , frozen_column
    , locked_column
    , description
    , last_modified_at_legacy
    , active
    , version
    , legacy_column_code
    , sync_column_code
    , hidden_column
    , required
    , editable
    , formula
    , format
    , width
    , data_type
    , last_modified_at
    , created_at
    , last_modified_by
    , created_by
    , record_status
FROM {{ ref('stg_scms_form_sheet_column') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')