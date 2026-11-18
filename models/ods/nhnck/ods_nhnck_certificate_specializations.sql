/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_certificate_specializations
* Program name: ODS NHNCK.CERTIFICATE_SPECIALIZATIONS
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
    , specialization_id
    , sort_order
    , document_type
    , is_required
FROM {{ ref('stg_nhnck_certificate_specializations') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
