/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_petition_target
* Program name: ODS THANHTRA.PETITION_TARGET
* Created by: tuan.nguyenvanb
* Created date: 2026-11-15
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-15		tuan.nguyenvanb		[MOI] ODS lay 1-1 tu stg_thanhtra_petition_target (doi tuong cua don thu). Loc ds_snpst_dt = etl_date va deleted = 0. Dung cho atm_petition lay target_nm giong cau BA (PETITION_TARGET).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , petition_id
    , target_type
    , target_reference_id
    , target_name
    , sort_order
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_petition_target') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0
