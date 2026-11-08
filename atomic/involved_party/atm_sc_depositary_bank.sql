/*
*--------------------------------------------------------------------*
* Program code: atm_sc_depositary_bank
* Program name: Atomic Securities Company Depositary Bank
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH bank AS (
    SELECT
        id
        , bank_name
        , name_en
        , short_name
        , enterprise_code
        , tax_code
        , charter_capital
        , category
        , operation_license_number
        , license_issue_date
        , license_issuer
        , settlement_bank_decision_number
        , settlement_bank_decision_date
        , settlement_start_date
        , settlement_function_description
        , business_reg_cert_number
        , business_reg_cert_date
        , custodian_start_date
        , custodian_member_cert_number
        , custodian_cert_date
        , custodian_member_code
        , custodian_function_description
        , attachment_path
        , note
        , input_report_data
        , record_status
    FROM {{ ref('ods_scms_bank') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK', "bank.id") }} AS sc_depositary_bank_id
    , CAST(bank.id AS string)                                   AS sc_depositary_bank_code
    , CAST('SCMS_BANK' AS string)                               AS src_stm_code
    , CAST(bank.bank_name AS string)                            AS sc_depositary_bank_nm
    , CAST(bank.name_en AS string)                              AS sc_depositary_bank_english_nm
    , CAST(bank.short_name AS string)                           AS sc_depositary_bank_short_nm
    , CAST(bank.enterprise_code AS string)                      AS enterprise_code
    , CAST(bank.tax_code AS string)                             AS tax_code
    , CAST(bank.charter_capital AS decimal(23,2))               AS charter_capital_amt
    , CAST(bank.category AS string)                             AS bank_category
    , CAST(bank.operation_license_number AS string)             AS operation_license_nbr
    , CAST(bank.license_issue_date AS date)                     AS license_issue_dt
    , CAST(bank.license_issuer AS string)                       AS license_issuer_nm
    , CAST(bank.settlement_bank_decision_number AS string)      AS settlement_bank_decision_nbr
    , CAST(bank.settlement_bank_decision_date AS date)          AS settlement_bank_decision_dt
    , CAST(bank.settlement_start_date AS date)                  AS settlement_start_dt
    , CAST(bank.settlement_function_description AS string)      AS settlement_function_description
    , CAST(bank.business_reg_cert_number AS string)             AS business_registration_certificate_nbr
    , CAST(bank.business_reg_cert_date AS date)                 AS business_registration_certificate_dt
    , CAST(bank.custodian_start_date AS date)                   AS custodian_start_dt
    , CAST(bank.custodian_member_cert_number AS string)         AS custodian_member_certificate_nbr
    , CAST(bank.custodian_cert_date AS date)                    AS custodian_certificate_dt
    , CAST(bank.custodian_member_code AS string)                AS custodian_member_code
    , CAST(bank.custodian_function_description AS string)       AS custodian_function_description
    , CAST(bank.attachment_path AS string)                      AS attachment_path
    , CAST(bank.note AS string)                                 AS note
    , CAST(bank.input_report_data AS int)                       AS input_rpt_data_indicator
    , CAST(bank.record_status AS string)                        AS record_status_code
FROM bank