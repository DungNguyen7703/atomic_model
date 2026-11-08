/*
*--------------------------------------------------------------------*
* Program code: ods_ids_categories
* Program name: ODS IDS.CATEGORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-29		tuan.nguyenvanb		[BA chot] Chi lay danh muc active_flg = 0 (active_flg = 1 bo): them WHERE active_flg = 0. Cong ty tro toi danh muc active_flg = 1 (vd DMX -> id 127507) khong con nganh -> 'Chua phan nganh'.
* 2026-10-30		tuan.nguyenvanb		Them dieu kien loc ODS chi lay ban ghi con hoat dong o nguon: status_flg = 1 (theo ma tran loc IDS).
* 2026-10-30		tuan.nguyenvanb		Them cot delete_flg (cuoi SELECT, sau id_sync) va dieu kien loc delete_flg = 0 theo ma tran loc IDS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , industry_cd
    , industry_name
    , description
    , parent_id
    , active_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , status_flg
    , id_sync
    , type
    , delete_flg
FROM {{ ref('stg_ids_categories') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
    AND status_flg = 1
    AND active_flg = 1