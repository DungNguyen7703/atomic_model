/*
*--------------------------------------------------------------------*
* Program code: atm_audit_firm
* Program name: Atomic Audit Firm
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_PROFILES.yaml (Fundamental -> scd4a). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        audit_firm_cd
        , full_name_vi
        , full_name_en
        , short_name
        , paid_in_capital
        , foreign_audit_member_flg
        , membership_start_date
        , membership_end_date
        , status_cd
        , external_id
        , foreign_audit_firm_name
        , approval_status_cd
        , approver_comment
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "src.audit_firm_cd") }} AS af_id
    , CAST(src.audit_firm_cd AS string)                                             AS af_code
    , CAST('AUDIT_AF_PROFILES' AS string)                                           AS src_stm_code
    , CAST(src.full_name_vi AS string)                                              AS af_nm
    , CAST(src.full_name_en AS string)                                              AS af_english_nm
    , CAST(src.short_name AS string)                                                AS af_short_nm
    , CAST(src.paid_in_capital AS decimal(23,2))                                    AS charter_capital_amt
    , CAST(src.foreign_audit_member_flg AS int)                                     AS foreign_audit_member_ind
    , CAST(src.foreign_audit_firm_name AS string)                                   AS foreign_af_nm
    , CAST(src.membership_start_date AS date)                                       AS membership_start_dt
    , CAST(src.membership_end_date AS date)                                         AS membership_end_dt
    , CAST(src.status_cd AS string)                                                 AS af_status_code
    , CAST(src.external_id AS bigint)                                               AS external_reference_id
    , CAST(src.approval_status_cd AS string)                                        AS approval_status_code
    , CAST(src.approver_comment AS string)                                          AS approver_comment
FROM src
