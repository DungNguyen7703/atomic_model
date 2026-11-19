/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_auditor_profiles
* Program name: ODS AUDIT.AF_AUDITOR_PROFILES
* Created by: ngoc.pham
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		ngoc.pham		[MOI] Bo sung ODS theo brd_AUDIT.yaml (in_scope, data_change_mode Update -> Snapshot); cot theo ODS DDL
* 2026-11-12		tuan.nguyenvanb	Them loc ban ghi dang hoat dong: delete_flg = 0 (DELETE_FLG: 1-Da xoa, 0-Dang hoat dong).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , full_name
    , identity_no
    , position_title_cd
    , practice_cert_no
    , practice_cert_issue_date
    , practice_start_date
    , practice_end_date
    , audit_cert_no
    , audit_cert_issue_date
    , status_cd
    , affiliation_end_date
    , rec_changed_flg
    , send_email
    , external_id
    , approval_status_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , approver_comment
    , is_working
FROM {{ ref('stg_audit_af_auditor_profiles') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
