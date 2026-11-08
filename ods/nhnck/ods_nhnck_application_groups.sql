/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_groups
* Program name: ODS NHNCK.APPLICATION_GROUPS
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
    , decision_id
    , group_created_date
    , group_completed_date
    , notes
    , application_count
    , created_at
    , updated_at
    , created_by
    , updated_by
    , application_type
    , submited_date
    , submited_by
FROM {{ ref('stg_nhnck_application_groups') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
