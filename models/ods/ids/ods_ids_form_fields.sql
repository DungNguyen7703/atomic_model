/*
*--------------------------------------------------------------------*
* Program code: ods_ids_form_fields
* Program name: ODS IDS.FORM_FIELDS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] ODS cho atomic atm_fr_x_fr_field_relationship (design dm_atm_fr_x_fr_field_relationship-IDS.FORM_FIELDS).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , field_id
    , field_parent_id
    , form_id
    , field_name_vi
    , field_name_en
    , data_type
    , field_order
    , parent_id
    , field_format
    , required_flg
    , correction_flg
    , published_flg
    , active_flg
    , doc_ref
    , created_by
    , created_date
    , last_updated_by
    , last_updated_date
    , system_cd
    , read_only_flg
    , write_flg
    , field_format_other
FROM {{ ref('stg_ids_form_fields') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
