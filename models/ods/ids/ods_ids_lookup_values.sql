/*
*--------------------------------------------------------------------*
* Program code: ods_ids_lookup_values
* Program name: ODS IDS.LOOKUP_VALUES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS IDS.LOOKUP_VALUES - loc ODS chi lay ban ghi con hoat dong o nguon: delete_flg = 0 AND active_flg = 1 (theo ma tran loc IDS).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , lookup_group
    , lookup_cd
    , lookup_value_vn
    , lookup_value_en
    , display_order
    , description
    , active_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , sync_flg
    , delete_flg
    , system_cd
    , lookup_parent_id
FROM {{ ref('stg_ids_lookup_values') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
    AND active_flg = 1
