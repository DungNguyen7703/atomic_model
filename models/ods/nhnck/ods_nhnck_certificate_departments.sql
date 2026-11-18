/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_certificate_departments
* Program name: ODS NHNCK.CERTIFICATE_DEPARTMENTS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Bo sung ODS (STG da co).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , certificate_id
    , department_id
FROM {{ ref('stg_nhnck_certificate_departments') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
