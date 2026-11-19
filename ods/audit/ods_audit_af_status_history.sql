/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_status_history
* Program name: ODS AUDIT.AF_STATUS_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS AUDIT.AF_STATUS_HISTORY - loc ODS chi lay ban ghi con hoat dong o nguon: delete_flg = 0 (theo ma tran loc AUDIT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , status_type
    , suspension_status_type
    , decision_no
    , decision_date
    , effective_from_date
    , effective_to_date
    , terminated_decision_date
    , reason
    , additional_desc
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_audit_af_status_history') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
