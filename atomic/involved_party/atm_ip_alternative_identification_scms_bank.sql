/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.BANK
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD SCMS lld_SCMS_BANK_IP_Alt_Identification.yaml] Tao moi model con theo LLD
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , enterprise_code
        , tax_code
        , operation_license_number
        , license_issue_date
        , license_issuer
        , business_reg_cert_number
        , business_reg_cert_date
    FROM {{ ref('ods_scms_bank') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK', "ba.id") }} AS ip_id
    , CAST(ba.id AS string)                                     AS ip_code
    , CAST('SCMS_BANK' AS string)                               AS src_stm_code
    , CAST('BUSINESS_LICENSE' AS string)                        AS identification_tp_code
    , CAST(ba.enterprise_code AS string)                        AS identification_nbr
    , CAST(NULL AS date)                                        AS identification_issue_dt
    , CAST(NULL AS string)                                      AS identification_issue_place
FROM src AS ba
WHERE ba.enterprise_code IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK', "ba.id") }} AS ip_id
    , CAST(ba.id AS string)                                     AS ip_code
    , CAST('SCMS_BANK' AS string)                               AS src_stm_code
    , CAST('TAX_ID' AS string)                                  AS identification_tp_code
    , CAST(ba.tax_code AS string)                               AS identification_nbr
    , CAST(NULL AS date)                                        AS identification_issue_dt
    , CAST(NULL AS string)                                      AS identification_issue_place
FROM src AS ba
WHERE ba.tax_code IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK', "ba.id") }} AS ip_id
    , CAST(ba.id AS string)                                     AS ip_code
    , CAST('SCMS_BANK' AS string)                               AS src_stm_code
    , CAST('ESTABLISHMENT_OPERATION_LICENSE' AS string)         AS identification_tp_code
    , CAST(ba.operation_license_number AS string)               AS identification_nbr
    , CAST(ba.license_issue_date AS date)                       AS identification_issue_dt
    , CAST(ba.license_issuer AS string)                         AS identification_issue_place
FROM src AS ba
WHERE ba.operation_license_number IS NOT NULL
