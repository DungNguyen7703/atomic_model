/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_INFO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_in AS (
    SELECT
        id
        , code
        , business_license_issuer
        , business_license_number
        , business_license_date
        , custodian_member_cert_number
        , custodian_member_cert_date
        , custody_reg_cert_decision_number
        , custody_reg_cert_decision_date
        , tax_code
        , CAST(NULL AS date) AS tax_issue_dt
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_in
    UNPIVOT (
        (identification_nbr, identification_issue_dt)
        FOR identification_tp_code IN (
            (business_license_number, business_license_date) AS BUSINESS_LICENSE,
            (custodian_member_cert_number, custodian_member_cert_date) AS CUSTODIAN_MEMBER_CERTIFICATE,
            (custody_reg_cert_decision_number, custody_reg_cert_decision_date) AS CUSTODY_REGISTRATION_CERTIFICATE,
            (tax_code, tax_issue_dt) AS TAX_ID
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "unpvt.code") }} AS ip_id
    , CAST(unpvt.code AS string)                                         AS ip_code
    , CAST('SCMS_SC_FIRM_INFO' AS string)                                AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                       AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                           AS identification_nbr
    , CAST(unpvt.identification_issue_dt AS date)                        AS identification_issue_dt
    , CASE WHEN unpvt.identification_tp_code = 'BUSINESS_LICENSE'
           THEN CAST(unpvt.business_license_issuer AS string)
           ELSE CAST(NULL AS string)
      END                                                                AS identification_issue_place

FROM unpvt