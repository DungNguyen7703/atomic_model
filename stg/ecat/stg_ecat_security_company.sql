/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_security_company
* Program name: Staging ECAT.SECURITY_COMPANY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu string sang decimal(19,0) (1 cot); them cot company_code, phone, foundation_license_issuer, foundation_license_no, foundation_license_date, listed, listing_date, listing_exchange, public_company, public_registration_date, public_termination_date, chartered_capital, id_sync, enterprise_type_code, enterprise_type_name, tax_code, enterprise_code, country_id, country_code, country_name, province_id, province_code, province_name, district_id, district_code, district_name, ward_id, ward_code, ward_name, foundation_license_file, official_operation_date, business_lines, total_shares, fiscal_year_end_date, financial_report_type, foreign_ownership_limit, ownership_limit_from_date, ownership_limit_to_date, public_company_decision_number, public_company_end_decision_number, status_code, status_name, custodian_member_code, custodian_member_cert_number, custodian_member_cert_date, custodian_revocation_decision, custodian_revocation_date, source_created_by, source_created_at, source_last_modified_by, source_last_modified_at, status_id; bo cot code, status, effective_date, expire_date, modified_date, province_new_id, district_old_id, ward_new_id, phone_number, represent, manager, gpkd_place, gpkd_number, gpkd_date, securities_business_activities, listed_flag, listed_date, market, public_company_flag, public_company_register_date, public_company_end_date, disclosure_officer, disclosure_email, enterprise_type_version_id, province_new_version_id, district_old_version_id, ward_new_version_id, charter_capital.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                AS id
    , CAST(company_code AS string)                       AS company_code
    , CAST(security_code AS string)                   AS security_code
    , CAST(company_name AS string)                    AS company_name
    , CAST(company_name_en AS string)                 AS company_name_en
    , CAST(short_name AS string)                      AS short_name
    , CAST(address AS string)                         AS address
    , CAST(phone AS string)                              AS phone
    , CAST(fax AS string)                             AS fax
    , CAST(email AS string)                           AS email
    , CAST(website AS string)                         AS website
    , CAST(foundation_license_issuer AS string)          AS foundation_license_issuer
    , CAST(foundation_license_no AS string)              AS foundation_license_no
    , CAST(foundation_license_date AS timestamp)         AS foundation_license_date
    , CAST(listed AS int)                                AS listed
    , CAST(listing_date AS timestamp)                    AS listing_date
    , CAST(listing_exchange AS string)                   AS listing_exchange
    , CAST(public_company AS int)                        AS public_company
    , CAST(public_registration_date AS timestamp)        AS public_registration_date
    , CAST(public_termination_date AS timestamp)         AS public_termination_date
    , CAST(active AS int)                             AS active
    , CAST(active_reason AS string)                   AS active_reason
    , CAST(deleted AS int)                            AS deleted
    , CAST(deleted_reason AS string)                  AS deleted_reason
    , CAST(version AS int)                            AS version
    , CAST(effective_start_date AS timestamp)         AS effective_start_date
    , CAST(effective_end_date AS timestamp)           AS effective_end_date
    , CAST(old_id AS string)                          AS old_id
    , CAST(created_at AS timestamp)                   AS created_at
    , CAST(updated_at AS timestamp)                   AS updated_at
    , CAST(created_by_id AS string)                   AS created_by_id
    , CAST(created_by_name AS string)                 AS created_by_name
    , CAST(updated_by_id AS string)                   AS updated_by_id
    , CAST(updated_by_name AS string)                 AS updated_by_name
    , CAST(stable_id AS string)                       AS stable_id
    , CAST(chartered_capital AS decimal(38,4))           AS chartered_capital
    , CAST(id_sync AS decimal(19,0))                     AS id_sync
    , CAST(enterprise_type_id AS decimal(19,0))          AS enterprise_type_id
    , CAST(enterprise_type_code AS string)               AS enterprise_type_code
    , CAST(enterprise_type_name AS string)               AS enterprise_type_name
    , CAST(tax_code AS string)                           AS tax_code
    , CAST(enterprise_code AS string)                    AS enterprise_code
    , CAST(country_id AS decimal(19,0))                  AS country_id
    , CAST(country_code AS string)                       AS country_code
    , CAST(country_name AS string)                       AS country_name
    , CAST(province_id AS decimal(19,0))                 AS province_id
    , CAST(province_code AS string)                      AS province_code
    , CAST(province_name AS string)                      AS province_name
    , CAST(district_id AS decimal(19,0))                 AS district_id
    , CAST(district_code AS string)                      AS district_code
    , CAST(district_name AS string)                      AS district_name
    , CAST(ward_id AS decimal(19,0))                     AS ward_id
    , CAST(ward_code AS string)                          AS ward_code
    , CAST(ward_name AS string)                          AS ward_name
    , CAST(foundation_license_file AS string)            AS foundation_license_file
    , CAST(official_operation_date AS timestamp)         AS official_operation_date
    , CAST(business_lines AS string)                     AS business_lines
    , CAST(total_shares AS decimal(38,0))                AS total_shares
    , CAST(fiscal_year_end_date AS string)               AS fiscal_year_end_date
    , CAST(financial_report_type AS string)              AS financial_report_type
    , CAST(foreign_ownership_limit AS decimal(9,4))      AS foreign_ownership_limit
    , CAST(ownership_limit_from_date AS timestamp)       AS ownership_limit_from_date
    , CAST(ownership_limit_to_date AS timestamp)         AS ownership_limit_to_date
    , CAST(public_company_decision_number AS string)     AS public_company_decision_number
    , CAST(public_company_end_decision_number AS string) AS public_company_end_decision_number
    , CAST(status_code AS string)                        AS status_code
    , CAST(status_name AS string)                        AS status_name
    , CAST(custodian_member_code AS string)              AS custodian_member_code
    , CAST(custodian_member_cert_number AS string)       AS custodian_member_cert_number
    , CAST(custodian_member_cert_date AS timestamp)      AS custodian_member_cert_date
    , CAST(custodian_revocation_decision AS string)      AS custodian_revocation_decision
    , CAST(custodian_revocation_date AS timestamp)       AS custodian_revocation_date
    , CAST(source_created_by AS decimal(19,0))           AS source_created_by
    , CAST(source_created_at AS timestamp)               AS source_created_at
    , CAST(source_last_modified_by AS decimal(19,0))     AS source_last_modified_by
    , CAST(source_last_modified_at AS timestamp)         AS source_last_modified_at
    , CAST(status_id AS string)                          AS status_id
FROM {{ source('source_ecat', 'raw_security_company') }}