/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_education_levels
* Program name: ODS NHNCK.EDUCATION_LEVELS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD NHNCK (STG da co).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , level_name
    , description
    , is_displayed
    , is_original_data
    , status
    , updated_at
    , created_at
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_education_levels') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')