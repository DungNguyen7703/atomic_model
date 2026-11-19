/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_profiles
* Program name: ODS AUDIT.AF_PROFILES
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
    , audit_firm_cd
    , full_name_vi
    , full_name_en
    , short_name
    , business_reg_no
    , eligibility_cert_no
    , address
    , phone_no
    , fax_no
    , website
    , paid_in_capital
    , foreign_audit_member_flg
    , membership_start_date
    , membership_end_date
    , status_cd
    , external_id
    , created_by
    , created_date
    , updated_by
    , updated_date
    , foreign_audit_firm_name
    , approval_status_cd
    , approver_comment
    , delete_flg
FROM {{ ref('stg_audit_af_profiles') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
