/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_group_members
* Program name: ODS NHNCK.APPLICATION_GROUP_MEMBERS
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
    , application_group_id
    , application_id
    , status
    , notes
    , order_index
FROM {{ ref('stg_nhnck_application_group_members') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
