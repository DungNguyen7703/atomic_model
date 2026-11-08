/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_penalty_type_violation_behavior
* Program name: ODS THANHTRA.PENALTY_TYPE_VIOLATION_BEHAVIOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD THANHTRA.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , penalty_type_id
    , violation_behavior_id
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_penalty_type_violation_behavior') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0