/*
*--------------------------------------------------------------------*
* Program code: atm_af_auditor_practice_history
* Program name: Atomic Af Auditor Practice History
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_AUDITOR_PRACTICE_HISTORY.yaml (Relative -> scd2). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_auditor_profile_id
        , practice_from_date
        , practice_to_date
        , practice_organization_id
    FROM {{ ref('ods_audit_af_auditor_practice_history') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PRACTICE_HISTORY', "src.id") }}            AS af_auditor_practice_history_id
    , CAST(src.id AS string)                                                                        AS af_auditor_practice_history_code
    , CAST('AUDIT_AF_AUDITOR_PRACTICE_HISTORY' AS string)                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "src.af_auditor_profile_id") }} AS af_auditor_id
    , CAST(src.af_auditor_profile_id AS string)                                                     AS af_auditor_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }}                 AS af_id
    , CAST(afp.audit_firm_cd AS string)                                                             AS af_code
    , CAST(src.practice_from_date AS date)                                                          AS practice_from_dt
    , CAST(src.practice_to_date AS date)                                                            AS practice_to_dt
FROM src
    LEFT JOIN afp ON src.practice_organization_id = afp.id
