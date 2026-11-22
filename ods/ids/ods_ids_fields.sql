/*
*--------------------------------------------------------------------*
* Program code: ods_ids_fields
* Program name: ODS IDS.FIELDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): delete_flg = 0 AND active_flg = 1
*--------------------------------------------------------------------*
*/

SELECT
    id
    , field_name_vi
    , field_name_en
    , data_type
    , repeatable_flg
    , form_type
    , parent_id
    , lookup_group
    , control_unit_cd
    , operating_unit_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , active_flg
FROM {{ ref('stg_ids_fields') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND delete_flg = 0
  AND active_flg = 1