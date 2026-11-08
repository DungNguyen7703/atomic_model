/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_auditor_profiles
* Program name: Staging AUDIT.AF_AUDITOR_PROFILES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(af_profile_id AS int)             AS af_profile_id
    , CAST(full_name AS string)              AS full_name
    , CAST(identity_no AS string)            AS identity_no
    , CAST(position_title_cd AS string)      AS position_title_cd
    , CAST(practice_cert_no AS string)       AS practice_cert_no
    , CAST(practice_cert_issue_date AS date) AS practice_cert_issue_date
    , CAST(practice_start_date AS date)      AS practice_start_date
    , CAST(practice_end_date AS date)        AS practice_end_date
    , CAST(audit_cert_no AS string)          AS audit_cert_no
    , CAST(audit_cert_issue_date AS date)    AS audit_cert_issue_date
    , CAST(status_cd AS string)              AS status_cd
    , CAST(affiliation_end_date AS date)     AS affiliation_end_date
    , CAST(rec_changed_flg AS int)           AS rec_changed_flg
    , CAST(send_email AS int)                AS send_email
    , CAST(external_id AS int)               AS external_id
    , CAST(approval_status_cd AS string)     AS approval_status_cd
    , CAST(created_by AS string)             AS created_by
    , CAST(created_date AS date)             AS created_date
    , CAST(updated_by AS string)             AS updated_by
    , CAST(updated_date AS date)             AS updated_date
    , CAST(delete_flg AS int)                AS delete_flg
    , CAST(approver_comment AS string)       AS approver_comment
    , CAST(is_working AS int)                AS is_working
FROM {{ source('source_audit', 'raw_af_auditor_profiles') }}