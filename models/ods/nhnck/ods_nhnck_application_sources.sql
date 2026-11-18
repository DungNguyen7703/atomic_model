/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_sources
* Program name: ODS NHNCK.APPLICATION_SOURCES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Bo sung ODS (STG da co) de phuc vu atm_cl_value_nhnck_application_sources.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , code
    , name
    , label
    , status
    , description
    , created_by
    , updated_by
    , created_at
    , updated_at
FROM {{ ref('stg_nhnck_application_sources') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
