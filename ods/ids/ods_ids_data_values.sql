/*
*--------------------------------------------------------------------*
* Program code: ods_ids_data_values
* Program name: ODS IDS.DATA_VALUES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] ODS cho atomic atm_fr_field_value (design dm_atm_fr_field_value-IDS.DATA_VALUES).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , field_name_vi
    , field_name_en
    , text_value
    , date_value
    , number_value
    , company_data_id
    , parent_id
    , form_id
    , field_id
    , form_field_id
    , field_parent_id
    , data_type
    , required_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_data_values') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
