/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_organization_report_yearlys
* Program name: ODS NHNCK.ORGANIZATION_REPORT_YEARLYS
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
    , organization_id
    , name
    , submission_date
    , year
    , type
    , file_path
    , status
    , created_at
    , updated_at
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_organization_report_yearlys') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
