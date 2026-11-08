/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_info
* Program name: Staging SCMS.SC_FIRM_INFO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                       AS id
    , CAST(sc_firm_info_id AS bigint)                          AS sc_firm_info_id
    , CAST(code AS string)                                     AS code
    , CAST(short_name AS string)                               AS short_name
    , CAST(name_vi AS string)                                  AS name_vi
    , CAST(name_en AS string)                                  AS name_en
    , CAST(address AS string)                                  AS address
    , CAST(province_id AS bigint)                              AS province_id
    , CAST(district_name AS string)                            AS district_name
    , CAST(ward_name AS string)                                AS ward_name
    , CAST(country_id AS bigint)                               AS country_id
    , CAST(phone AS string)                                    AS phone
    , CAST(fax AS string)                                      AS fax
    , CAST(email AS string)                                    AS email
    , CAST(website AS string)                                  AS website
    , CAST(charter_capital AS decimal(38,0))                   AS charter_capital
    , CAST(tax_code AS string)                                 AS tax_code
    , CAST(business_license_number AS string)                  AS business_license_number
    , CAST(business_license_date AS date)                      AS business_license_date
    , CAST(business_license_issuer AS string)                  AS business_license_issuer
    , CAST(company_type_id AS bigint)                          AS company_type_id
    , CAST(total_shares AS decimal(38,0))                      AS total_shares
    , CAST(business_lines AS string)                           AS business_lines
    , CAST(listed AS int)                                      AS listed
    , CAST(listing_exchange AS string)                         AS listing_exchange
    , CAST(securities_code AS string)                          AS securities_code
    , CAST(sc_firm_registration_date AS date)                  AS sc_firm_registration_date
    , CAST(decision_number AS string)                          AS decision_number
    , CAST(license_expiry_date AS date)                        AS license_expiry_date
    , CAST(termination_decision_number AS string)              AS termination_decision_number
    , CAST(created_by AS bigint)                               AS created_by
    , CAST(created_at AS timestamp)                            AS created_at
    , CAST(last_modified_by AS bigint)                         AS last_modified_by
    , CAST(last_modified_at AS timestamp)                      AS last_modified_at
    , CAST(record_status AS bigint)                            AS record_status
    , CAST(provisional AS int)                                 AS provisional
    , CAST(enterprise_code AS string)                          AS enterprise_code
    , CAST(electronic_trading_status AS string)                AS electronic_trading_status
    , CAST(electronic_trading_decision_number AS string)       AS electronic_trading_decision_number
    , CAST(electronic_trading_decision_date AS date)           AS electronic_trading_decision_date
    , CAST(electronic_trading_reason AS string)                AS electronic_trading_reason
    , CAST(note AS string)                                     AS note
    , CAST(attachment_path AS string)                          AS attachment_path
    , CAST(additional_business_lines AS string)                AS additional_business_lines
    , CAST(district_id AS bigint)                              AS district_id
    , CAST(ward_id AS bigint)                                  AS ward_id
    , CAST(certificate_number AS string)                       AS certificate_number
    , CAST(listing_date AS date)                               AS listing_date
    , CAST(custodian_cert_number AS string)                    AS custodian_cert_number
    , CAST(custodian_cert_date AS date)                        AS custodian_cert_date
    , CAST(public_company_registration_date AS date)           AS public_company_registration_date
    , CAST(public_company_decision_number AS string)           AS public_company_decision_number
    , CAST(synced_from_admin_proc AS int)                      AS synced_from_admin_proc
    , CAST(amendment_declaration AS int)                       AS amendment_declaration
    , CAST(amendment_document_number AS string)                AS amendment_document_number
    , CAST(amendment_effective_date AS date)                   AS amendment_effective_date
    , CAST(amendment_document_file AS string)                  AS amendment_document_file
    , CAST(public_company AS int)                              AS public_company
    , CAST(event_type_id AS bigint)                            AS event_type_id
    , CAST(foundation_license_file AS string)                  AS foundation_license_file
    , CAST(ownership_limit_to_date AS date)                    AS ownership_limit_to_date
    , CAST(ownership_limit_from_date AS date)                  AS ownership_limit_from_date
    , CAST(foreign_investor_ownership_limit AS decimal(9,4))   AS foreign_investor_ownership_limit
    , CAST(business_license AS string)                         AS business_license
    , CAST(financial_report_type AS string)                    AS financial_report_type
    , CAST(custodian_member_code AS string)                    AS custodian_member_code
    , CAST(custodian_member_cert_date AS date)                 AS custodian_member_cert_date
    , CAST(foundation_license_date AS date)                    AS foundation_license_date
    , CAST(official_operation_date AS date)                    AS official_operation_date
    , CAST(amendment_expiry_date AS date)                      AS amendment_expiry_date
    , CAST(public_company_end_date AS date)                    AS public_company_end_date
    , CAST(fiscal_year_end_date AS string)                     AS fiscal_year_end_date
    , CAST(amendment_document_date AS date)                    AS amendment_document_date
    , CAST(foundation_license_issuer AS string)                AS foundation_license_issuer
    , CAST(custodian_member_cert_number AS string)             AS custodian_member_cert_number
    , CAST(foundation_license_number AS string)                AS foundation_license_number
    , CAST(public_company_end_decision_number AS string)       AS public_company_end_decision_number
    , CAST(form_data_json AS string)                           AS form_data_json
    , CAST(custodian_membership_revocation_decision AS string) AS custodian_membership_revocation_decision
    , CAST(custodian_membership_revocation_date AS date)       AS custodian_membership_revocation_date
    , CAST(last_modified_by_alt AS decimal(19,0))              AS last_modified_by_alt
    , CAST(trading_registered AS int)                          AS trading_registered
    , CAST(custody_reg_cert_decision_number AS string)         AS custody_reg_cert_decision_number
    , CAST(custody_reg_cert_decision_date AS date)             AS custody_reg_cert_decision_date
    , CAST(deleted AS int)                                     AS deleted
    , CAST(business_reg_cert_number AS string)                 AS business_reg_cert_number
    , CAST(business_reg_cert_date AS date)                     AS business_reg_cert_date
    , CAST(business_reg_cert_issuer AS string)                 AS business_reg_cert_issuer
FROM {{ source('source_scms', 'raw_sc_firm_info') }}