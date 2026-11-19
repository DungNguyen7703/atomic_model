/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_auditor_practice_history
* Program name: ODS AUDIT.AF_AUDITOR_PRACTICE_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS AUDIT.AF_AUDITOR_PRACTICE_HISTORY - khong loc (theo ma tran loc AUDIT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_auditor_profile_id
    , practice_from_date
    , practice_to_date
    , practice_organization_id
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_audit_af_auditor_practice_history') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
