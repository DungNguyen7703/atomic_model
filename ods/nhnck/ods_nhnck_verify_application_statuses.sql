/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_verify_application_statuses
* Program name: ODS NHNCK.VERIFY_APPLICATION_STATUSES
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
    , application_id
    , status_id
    , prev_status_id
    , status
    , reason
    , spec_reason
    , org_reason
    , overview_reason
    , overview_file_path
    , verified_by
    , created_by
    , created_at
    , updated_by
    , updated_at
FROM {{ ref('stg_nhnck_verify_application_statuses') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
