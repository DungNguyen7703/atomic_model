/*
*--------------------------------------------------------------------*
* Program code: atm_af_auditor
* Program name: Atomic Af Auditor
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_AUDITOR_PROFILES.yaml (Fundamental -> scd4a). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , full_name
        , position_title_cd
        , practice_start_date
        , practice_end_date
        , status_cd
        , affiliation_end_date
        , send_email
        , external_id
        , approval_status_cd
        , approver_comment
        , is_working
    FROM {{ ref('ods_audit_af_auditor_profiles') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "src.id") }}    AS af_auditor_id
    , CAST(src.id AS string)                                                        AS af_auditor_code
    , CAST('AUDIT_AF_AUDITOR_PROFILES' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }} AS af_id
    , CAST(afp.audit_firm_cd AS string)                                             AS af_code
    , CAST(src.full_name AS string)                                                 AS af_auditor_nm
    , CAST(src.position_title_cd AS string)                                         AS position_title_code
    , CAST(src.practice_start_date AS date)                                         AS practice_start_dt
    , CAST(src.practice_end_date AS date)                                           AS practice_end_dt
    , CAST(src.status_cd AS string)                                                 AS auditor_status_code
    , CAST(src.affiliation_end_date AS date)                                        AS affiliation_end_dt
    , CAST(src.send_email AS int)                                                   AS email_sent_ind
    , CAST(src.external_id AS bigint)                                               AS external_reference_id
    , CAST(src.approval_status_cd AS string)                                        AS approval_status_code
    , CAST(src.approver_comment AS string)                                          AS approver_comment
    , CAST(src.is_working AS int)                                                   AS working_ind
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
