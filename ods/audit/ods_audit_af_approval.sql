/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_approval
* Program name: ODS AUDIT.AF_APPROVAL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS AUDIT.AF_APPROVAL - loc ODS chi lay ban ghi con hoat dong o nguon: delete_flg = 0 (theo ma tran loc AUDIT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , af_auditor_profile_id
    , target_type_cd
    , source_type_cd
    , approval_doc_no
    , approval_issue_date
    , approval_start_date
    , approval_end_date
    , approval_content
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , affiliation_end_date
    , affiliation_no
    , affiliation_change_reason
FROM {{ ref('stg_audit_af_approval') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
