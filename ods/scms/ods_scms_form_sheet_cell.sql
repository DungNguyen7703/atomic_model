/*
*--------------------------------------------------------------------*
* Program code: ods_scms_form_sheet_cell
* Program name: ODS SCMS.FORM_SHEET_CELL
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
    , form_report_id
    , form_sheet_id
    , indicator_id
    , form_sheet_column_id
    , form_sheet_row_id
    , form_sheet_cell_input_id
    , format
    , unit
    , default_value_legacy
    , sort_order
    , description
    , last_modified_at
    , active
    , version
    , label
    , style_format
    , color
    , alignment
    , bold
    , italic
    , uppercase
    , underline
    , character_format
    , filter_id
    , sum_formula
    , formula_text
    , formula
    , required
    , template_form_report_id
    , editable
    , col_span
    , dropdown_data
    , default_value
    , max_value
    , min_value
    , data_type
    , cell_code
    , last_modified_at_alt
    , created_at
    , last_modified_by
    , created_by
    , row_span
    , record_status
    , is_total
FROM {{ ref('stg_scms_form_sheet_cell') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')