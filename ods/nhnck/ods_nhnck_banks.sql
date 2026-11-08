/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_banks
* Program name: ODS NHNCK.BANKS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Bo sung ODS (STG da co) de phuc vu atm_cl_value_nhnck_banks.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , bank_code
    , bank_name
    , short_name
    , bank_key
    , english_bank_name
    , created_at
    , updated_at
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_banks') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
