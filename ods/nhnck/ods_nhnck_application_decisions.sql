/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_decisions
* Program name: ODS NHNCK.APPLICATION_DECISIONS
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
    , decision_id
FROM {{ ref('stg_nhnck_application_decisions') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
