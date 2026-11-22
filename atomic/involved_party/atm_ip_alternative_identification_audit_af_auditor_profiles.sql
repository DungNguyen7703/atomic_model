/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification_audit_af_auditor_profiles
* Program name: Atomic IP Alternative Identification AUDIT.AF_AUDITOR_PROFILES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh AUDIT theo lld_AUDIT_AF_AUDITOR_PROFILES_IP_Alt_Identification.yaml (3 block).
*--------------------------------------------------------------------*
*/

WITH af_au AS (
    SELECT
        id
        , identity_no
        , practice_cert_no
        , practice_cert_issue_date
        , audit_cert_no
        , audit_cert_issue_date
    FROM {{ ref('ods_audit_af_auditor_profiles') }}
    WHERE id IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "af_au.id") }} AS ip_id
    , CAST(af_au.id AS string)                                                     AS ip_code
    , CAST('AUDIT_AF_AUDITOR_PROFILES' AS string)                                  AS src_stm_code
    , CAST('CITIZEN_ID' AS string)                                                 AS identification_tp_code
    , CAST(af_au.identity_no AS string)                                            AS identification_nbr
    , CAST(NULL AS date)                                                           AS identification_issue_dt
    , CAST(NULL AS string)                                                         AS identification_issue_place
FROM af_au
WHERE af_au.identity_no IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "af_au.id") }} AS ip_id
    , CAST(af_au.id AS string)                                                     AS ip_code
    , CAST('AUDIT_AF_AUDITOR_PROFILES' AS string)                                  AS src_stm_code
    , CAST('PRACTITIONER_LICENSE' AS string)                                       AS identification_tp_code
    , CAST(af_au.practice_cert_no AS string)                                       AS identification_nbr
    , CAST(af_au.practice_cert_issue_date AS date)                                 AS identification_issue_dt
    , CAST(NULL AS string)                                                         AS identification_issue_place
FROM af_au
WHERE af_au.practice_cert_no IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "af_au.id") }} AS ip_id
    , CAST(af_au.id AS string)                                                     AS ip_code
    , CAST('AUDIT_AF_AUDITOR_PROFILES' AS string)                                  AS src_stm_code
    , CAST('AUDITOR_CERTIFICATE' AS string)                                        AS identification_tp_code
    , CAST(af_au.audit_cert_no AS string)                                          AS identification_nbr
    , CAST(af_au.audit_cert_issue_date AS date)                                    AS identification_issue_dt
    , CAST(NULL AS string)                                                         AS identification_issue_place
FROM af_au
WHERE af_au.audit_cert_no IS NOT NULL
