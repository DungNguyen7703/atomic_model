/*
*--------------------------------------------------------------------*
* Program code: atm_et_registration
* Program name: Atomic Et Registration
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_KNT_TAX_REGISTRATION_INFO.yaml (Fundamental -> scd4a). UAT chua co model KNT nao.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        msg_packet_id
        , taxpayer_name
        , tax_code
        , hq_address
        , phone
        , fax
        , charter_capital
        , business_line
        , license_number
        , issue_date
        , issuing_authority
        , decision_number
        , issued_date
        , issuing_org
        , supervising_unit
        , business_start_date
        , legal_representative_name
        , id_card_number
        , so_dien_thoai
        , director_name
        , director_phone
        , operation_status
        , suspension_reason
        , suspension_type
        , direct_supervising_authority
        , tax_authority_code
        , domestic_capital_currency
        , foreign_capital_amount
        , foreign_capital_currency
        , supervising_unit_address
        , business_address_desc
        , business_province_code
        , business_district_code
        , business_ward_code
        , business_phone
        , business_email
        , business_fax
        , suspension_from_date
        , suspension_to_date
        , suspension_reason_text
        , suspension_notice_number
        , suspension_notice_date
        , operation_stop_date
        , operation_stop_reason
        , operation_stop_note
        , operation_stop_notice_number
        , status_name
        , business_line_code
        , business_province_name
        , business_district_name
        , business_ward_name
        , foreign_capital_ratio
    FROM {{ ref('ods_knt_tax_registration_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('KNT_TAX_REGISTRATION_INFO', "src.tax_code") }} AS et_registration_id
    , CAST(src.tax_code AS string)                                                     AS et_registration_code
    , CAST('KNT_TAX_REGISTRATION_INFO' AS string)                                      AS src_stm_code
    , CAST(src.taxpayer_name AS string)                                                AS taxpayer_nm
    , CAST(src.charter_capital AS decimal(23,2))                                       AS charter_capital_amt
    , CAST(src.business_line_code AS string)                                           AS primary_business_line_code
    , CAST(src.business_line AS string)                                                AS primary_business_line_nm
    , CAST(src.license_number AS string)                                               AS business_license_nbr
    , CAST(src.issue_date AS date)                                                     AS business_license_issue_dt
    , CAST(src.issuing_authority AS string)                                            AS business_license_issuing_authority_nm
    , CAST(src.decision_number AS string)                                              AS establishment_decision_nbr
    , CAST(src.issued_date AS date)                                                    AS establishment_decision_issue_dt
    , CAST(src.issuing_org AS string)                                                  AS establishment_decision_issuing_organization_nm
    , CAST(src.supervising_unit AS string)                                             AS supervising_unit_nm
    , CAST(src.supervising_unit_address AS string)                                     AS supervising_unit_adr
    , CAST(src.business_start_date AS date)                                            AS business_start_dt
    , CAST(src.legal_representative_name AS string)                                    AS legal_representative_full_nm
    , CAST(src.id_card_number AS string)                                               AS legal_representative_identification_nbr
    , CAST(src.so_dien_thoai AS string)                                                AS legal_representative_phone_nbr
    , CAST(src.director_name AS string)                                                AS director_full_nm
    , CAST(src.director_phone AS string)                                               AS director_phone_nbr
    , CAST(src.operation_status AS string)                                             AS operation_status_code
    , CAST(src.status_name AS string)                                                  AS operation_status_nm
    , CAST(src.suspension_reason AS string)                                            AS suspension_reason_description
    , CAST(src.suspension_type AS string)                                              AS suspension_tp_code
    , CAST(src.direct_supervising_authority AS string)                                 AS direct_supervising_authority_nm
    , CAST(src.tax_authority_code AS string)                                           AS tax_authority_code
    , CAST(src.domestic_capital_currency AS string)                                    AS domestic_capital_currency_code
    , CAST(src.foreign_capital_amount AS decimal(23,2))                                AS foreign_capital_amt
    , CAST(src.foreign_capital_currency AS string)                                     AS foreign_capital_currency_code
    , CAST(src.foreign_capital_ratio AS decimal(5,2))                                  AS foreign_capital_ratio
    , CAST(src.suspension_from_date AS date)                                           AS temporary_suspension_from_dt
    , CAST(src.suspension_to_date AS date)                                             AS temporary_suspension_to_dt
    , CAST(src.suspension_reason_text AS string)                                       AS temporary_suspension_reason_description
    , CAST(src.suspension_notice_number AS string)                                     AS temporary_suspension_notice_nbr
    , CAST(src.suspension_notice_date AS date)                                         AS temporary_suspension_notice_dt
    , CAST(src.operation_stop_date AS date)                                            AS operation_stop_dt
    , CAST(src.operation_stop_reason AS string)                                        AS operation_stop_reason_description
    , CAST(src.operation_stop_note AS string)                                          AS operation_stop_note
    , CAST(src.operation_stop_notice_number AS string)                                 AS operation_stop_notice_nbr
    , CAST(src.msg_packet_id AS string)                                                AS message_packet_id
    , CAST(src.hq_address AS string)                                                   AS head_office_adr
    , CAST(src.business_address_desc AS string)                                        AS business_adr_description
    , CAST(src.business_province_code AS string)                                       AS business_province_code
    , CAST(src.business_province_name AS string)                                       AS business_province_nm
    , CAST(src.business_district_code AS string)                                       AS business_district_code
    , CAST(src.business_district_name AS string)                                       AS business_district_nm
    , CAST(src.business_ward_code AS string)                                           AS business_ward_code
    , CAST(src.business_ward_name AS string)                                           AS business_ward_nm
    , CAST(src.phone AS string)                                                        AS phone_nbr
    , CAST(src.fax AS string)                                                          AS fax_nbr
    , CAST(src.business_phone AS string)                                               AS business_phone_nbr
    , CAST(src.business_fax AS string)                                                 AS business_fax_nbr
    , CAST(src.business_email AS string)                                               AS business_email_adr
FROM src
