/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_certificate_record_groups
* Program name: ODS NHNCK.CERTIFICATE_RECORD_GROUPS
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
    , group_name
    , description
    , status
    , type
    , decision_id
    , group_created_date
    , group_completed_date
    , notes
    , certificate_record_count
    , created_at
    , created_by
    , updated_at
    , updated_by
FROM {{ ref('stg_nhnck_certificate_record_groups') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
