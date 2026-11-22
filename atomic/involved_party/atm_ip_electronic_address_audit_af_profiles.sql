/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address_audit_af_profiles
* Program name: Atomic IP Electronic Address AUDIT.AF_PROFILES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh AUDIT theo lld_AUDIT_AF_PROFILES_IP_Electronic_Address.yaml (PHONE/FAX/WEBSITE).
*--------------------------------------------------------------------*
*/

WITH af_pr AS (
    SELECT
        audit_firm_cd
        , phone_no
        , fax_no
        , website
    FROM {{ ref('ods_audit_af_profiles') }}
    WHERE audit_firm_cd IS NOT NULL
),

unpvt AS (
    SELECT *
    FROM af_pr
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            phone_no AS PHONE,
            fax_no AS FAX,
            website AS WEBSITE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "unpvt.audit_firm_cd") }} AS ip_id
    , CAST(unpvt.audit_firm_cd AS string)                                             AS ip_code
    , CAST('AUDIT_AF_PROFILES' AS string)                                             AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                                    AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                        AS electronic_adr_val
FROM unpvt
