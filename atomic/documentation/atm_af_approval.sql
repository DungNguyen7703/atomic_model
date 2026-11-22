/*
*--------------------------------------------------------------------*
* Program code: atm_af_approval
* Program name: Atomic Af Approval
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_APPROVAL.yaml (Relative -> scd2). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
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
        , affiliation_end_date
        , affiliation_no
        , affiliation_change_reason
    FROM {{ ref('ods_audit_af_approval') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_APPROVAL', "src.id") }}                            AS af_approval_id
    , CAST(src.id AS string)                                                                        AS af_approval_code
    , CAST('AUDIT_AF_APPROVAL' AS string)                                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }}                 AS af_id
    , CAST(afp.audit_firm_cd AS string)                                                             AS af_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "src.af_auditor_profile_id") }} AS af_auditor_id
    , CAST(src.af_auditor_profile_id AS string)                                                     AS af_auditor_code
    , CAST(src.target_type_cd AS string)                                                            AS approval_target_tp_code
    , CAST(src.source_type_cd AS string)                                                            AS approval_src_tp_code
    , CAST(src.approval_doc_no AS string)                                                           AS approval_document_nbr
    , CAST(src.approval_issue_date AS date)                                                         AS approval_issue_dt
    , CAST(src.approval_start_date AS date)                                                         AS approval_start_dt
    , CAST(src.approval_end_date AS date)                                                           AS approval_end_dt
    , CAST(src.approval_content AS string)                                                          AS approval_content
    , CAST(src.affiliation_end_date AS date)                                                        AS affiliation_end_dt
    , CAST(src.affiliation_no AS string)                                                            AS affiliation_nbr
    , CAST(src.affiliation_change_reason AS string)                                                 AS affiliation_change_reason_description
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
