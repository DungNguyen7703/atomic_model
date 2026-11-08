/*
*--------------------------------------------------------------------*
* Program code: ods_ecat_region
* Program name: ODS ECAT.REGION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		Them dieu kien loc ODS chi lay ban ghi con hoat dong o nguon: deleted = 0 AND active = 1 AND effective_end_date IS NULL (theo ma tran loc ECAT).
* 2026-10-30		tuan.nguyenvanb		Them cot effective (cuoi SELECT, sau deleted_reason) va dieu kien loc effective = 1 theo ma tran loc ECAT.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , code
    , name
    , country_id
    , active
    , active_reason
    , deleted
    , version
    , effective_start_date
    , effective_end_date
    , old_id
    , created_at
    , updated_at
    , created_by_id
    , created_by_name
    , updated_by_id
    , updated_by_name
    , stable_id
    , country_version_id
    , deleted_reason
    , effective
FROM {{ ref('stg_ecat_region') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND effective = 1
    AND active = 1
    AND effective_end_date IS NULL