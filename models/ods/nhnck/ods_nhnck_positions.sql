/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_positions
* Program name: ODS NHNCK.POSITIONS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Bo sung ODS (STG da co) de phuc vu atm_cl_value_nhnck_positions.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , position_name
    , description
    , created_at
    , created_by
    , updated_at
    , is_active
    , status
    , updated_by
    , ecatalog_id
    , position_code
FROM {{ ref('stg_nhnck_positions') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
