/*
*--------------------------------------------------------------------*
* Program code: atm_sc_bank
* Program name: Atomic Securities Company Bank
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_SCMS_BANK.yaml (doi ten tu atm_sc_depositary_bank).
*--------------------------------------------------------------------*
*/

WITH bank AS (
    SELECT
        id
        , bank_name
        , name_en
        , short_name
        , enterprise_code
        , charter_capital
        , category
        , settlement_bank_decision_number
        , settlement_bank_decision_date
        , settlement_start_date
        , custodian_start_date
        , custodian_member_cert_number
        , custodian_cert_date
        , custodian_member_code
        , attachment_path
        , input_report_data
        , record_status
    FROM {{ ref('ods_scms_bank') }}
),

ca_sc_fi_st AS (
    SELECT
        id
        , sc_firm_status_code
    FROM {{ ref('ods_scms_cat_sc_firm_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK', "bank.id") }}                                         AS sc_bank_id
    , CAST(bank.id AS string)                                                                           AS sc_bank_code
    , CAST('SCMS_BANK' AS string)                                                                       AS src_stm_code
    , CAST(bank.bank_name AS string)                                                                    AS sc_bank_nm
    , CAST(bank.name_en AS string)                                                                      AS sc_bank_english_nm
    , CAST(bank.short_name AS string)                                                                   AS sc_bank_short_nm
    , CAST(bank.enterprise_code AS string)                                                              AS enterprise_code
    , CAST(bank.charter_capital AS decimal(23,2))                                                       AS charter_capital_amt
    , CAST(bank.category AS string)                                                                     AS bank_category
    , CAST(bank.settlement_bank_decision_number AS string)                                              AS settlement_bank_decision_nbr
    , CAST(bank.settlement_bank_decision_date AS date)                                                  AS settlement_bank_decision_dt
    , CAST(bank.settlement_start_date AS date)                                                          AS settlement_start_dt
    , CAST(bank.custodian_start_date AS date)                                                           AS custodian_start_dt
    , CAST(bank.custodian_member_cert_number AS string)                                                 AS custodian_member_certificate_nbr
    , CAST(bank.custodian_cert_date AS date)                                                            AS custodian_certificate_dt
    , CAST(bank.custodian_member_code AS string)                                                        AS custodian_member_code
    , CAST(bank.attachment_path AS string)                                                              AS attachment_path
    , CAST(bank.input_report_data AS int)                                                               AS input_rpt_data_ind
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "ca_sc_fi_st.sc_firm_status_code") }} AS cl_sc_firm_status_id
    , CAST(ca_sc_fi_st.sc_firm_status_code AS string)                                                   AS cl_sc_firm_status_code
FROM bank
    LEFT JOIN ca_sc_fi_st ON CAST(bank.record_status AS string) = CAST(ca_sc_fi_st.id AS string)
