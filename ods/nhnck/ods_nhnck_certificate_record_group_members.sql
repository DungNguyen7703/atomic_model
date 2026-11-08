/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_certificate_record_group_members
* Program name: ODS NHNCK.CERTIFICATE_RECORD_GROUP_MEMBERS
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
    , certificate_record_group_id
    , certificate_record_id
    , added_date
    , added_by
    , status
    , is_reissue
    , revocation_reason
    , order_index
FROM {{ ref('stg_nhnck_certificate_record_group_members') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
