/*
*--------------------------------------------------------------------*
* Program code: ods_ids_provinces
* Program name: ODS IDS.PROVINCES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD IDS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , province_cd
    , province_name_vn
    , province_name_en
    , region
    , created_by
    , created_date
    , updated_by
    , updated_date
    , description
    , active_flg
    , status_flg
    , system_cd
FROM {{ ref('stg_ids_provinces') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')