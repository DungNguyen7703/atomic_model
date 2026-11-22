/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address_audit_af_profiles
* Program name: Atomic IP Postal Address AUDIT.AF_PROFILES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh AUDIT theo lld_AUDIT_AF_PROFILES_IP_Postal_Address.yaml (HEAD_OFFICE).
*--------------------------------------------------------------------*
*/

WITH af_pr AS (
    SELECT
        audit_firm_cd
        , address
    FROM {{ ref('ods_audit_af_profiles') }}
    WHERE audit_firm_cd IS NOT NULL
      AND address IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "af_pr.audit_firm_cd") }} AS ip_id
    , CAST(af_pr.audit_firm_cd AS string)                                             AS ip_code
    , CAST('AUDIT_AF_PROFILES' AS string)                                             AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                                   AS adr_tp_code
    , CAST(af_pr.address AS string)                                                   AS adr_val
    , CAST(NULL AS string)                                                            AS country_id
    , CAST(NULL AS string)                                                            AS country_code
    , CAST(NULL AS string)                                                            AS province_id
    , CAST(NULL AS string)                                                            AS province_code
    , CAST(NULL AS string)                                                            AS district_id
    , CAST(NULL AS string)                                                            AS district_code
    , CAST(NULL AS string)                                                            AS ward_id
    , CAST(NULL AS string)                                                            AS ward_code
FROM af_pr
