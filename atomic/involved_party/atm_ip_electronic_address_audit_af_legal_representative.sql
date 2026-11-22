/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address_audit_af_legal_representative
* Program name: Atomic IP Electronic Address AUDIT.AF_LEGAL_REPRESENTATIVE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh AUDIT theo lld_AUDIT_AF_LEGAL_REPRESENTATIVE_IP_Electronic_Address.yaml (PHONE).
*--------------------------------------------------------------------*
*/

WITH af_lr AS (
    SELECT
        id
        , phone_no
    FROM {{ ref('ods_audit_af_legal_representative') }}
    WHERE id IS NOT NULL
      AND phone_no IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_LEGAL_REPRESENTATIVE', "af_lr.id") }} AS ip_id
    , CAST(af_lr.id AS string)                                                         AS ip_code
    , CAST('AUDIT_AF_LEGAL_REPRESENTATIVE' AS string)                                  AS src_stm_code
    , CAST('PHONE' AS string)                                                          AS electronic_adr_tp_code
    , CAST(af_lr.phone_no AS string)                                                   AS electronic_adr_val
FROM af_lr
