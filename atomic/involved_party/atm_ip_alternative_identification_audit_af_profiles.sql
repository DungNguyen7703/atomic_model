/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification_audit_af_profiles
* Program name: Atomic IP Alternative Identification AUDIT.AF_PROFILES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh AUDIT theo lld_AUDIT_AF_PROFILES_IP_Alt_Identification.yaml (2 block).
*--------------------------------------------------------------------*
*/

WITH af_pr AS (
    SELECT
        audit_firm_cd
        , business_reg_no
        , eligibility_cert_no
    FROM {{ ref('ods_audit_af_profiles') }}
    WHERE audit_firm_cd IS NOT NULL
),

unpvt AS (
    SELECT *
    FROM af_pr
    UNPIVOT (
        identification_nbr
        FOR identification_tp_code IN (
            business_reg_no AS BUSINESS_LICENSE,
            eligibility_cert_no AS ELIGIBILITY_CERTIFICATE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "unpvt.audit_firm_cd") }} AS ip_id
    , CAST(unpvt.audit_firm_cd AS string)                                             AS ip_code
    , CAST('AUDIT_AF_PROFILES' AS string)                                             AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                                    AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                                        AS identification_nbr
    , CAST(NULL AS date)                                                              AS identification_issue_dt
    , CAST(NULL AS string)                                                            AS identification_issue_place
FROM unpvt
