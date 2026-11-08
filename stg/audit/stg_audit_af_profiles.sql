/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_profiles
* Program name: Staging AUDIT.AF_PROFILES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(audit_firm_cd AS string)           AS audit_firm_cd
    , CAST(full_name_vi AS string)            AS full_name_vi
    , CAST(full_name_en AS string)            AS full_name_en
    , CAST(short_name AS string)              AS short_name
    , CAST(business_reg_no AS string)         AS business_reg_no
    , CAST(eligibility_cert_no AS string)     AS eligibility_cert_no
    , CAST(address AS string)                 AS address
    , CAST(phone_no AS string)                AS phone_no
    , CAST(fax_no AS string)                  AS fax_no
    , CAST(website AS string)                 AS website
    , CAST(paid_in_capital AS bigint)         AS paid_in_capital
    , CAST(foreign_audit_member_flg AS int)   AS foreign_audit_member_flg
    , CAST(membership_start_date AS date)     AS membership_start_date
    , CAST(membership_end_date AS date)       AS membership_end_date
    , CAST(status_cd AS string)               AS status_cd
    , CAST(external_id AS int)                AS external_id
    , CAST(created_by AS string)              AS created_by
    , CAST(created_date AS date)              AS created_date
    , CAST(updated_by AS string)              AS updated_by
    , CAST(updated_date AS date)              AS updated_date
    , CAST(foreign_audit_firm_name AS string) AS foreign_audit_firm_name
    , CAST(approval_status_cd AS string)      AS approval_status_cd
    , CAST(approver_comment AS string)        AS approver_comment
    , CAST(delete_flg AS int)                 AS delete_flg
FROM {{ source('source_audit', 'raw_af_profiles') }}