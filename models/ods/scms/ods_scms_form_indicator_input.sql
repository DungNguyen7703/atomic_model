/*
*--------------------------------------------------------------------*
* Program code: ods_scms_form_indicator_input
* Program name: ODS SCMS.FORM_INDICATOR_INPUT
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
    , code
    , item_name
    , description
    , data_type
    , reference_catalog_id
    , record_status
    , created_by
    , updated_by
    , created_at
    , last_modified_at
    , reference_catalog_type
    , category
    , source_entity_code
    , field_metadata_id
    , selection_list_source
FROM {{ ref('stg_scms_form_indicator_input') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')