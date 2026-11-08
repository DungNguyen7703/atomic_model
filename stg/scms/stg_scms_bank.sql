/*
*--------------------------------------------------------------------*
* Program code: stg_scms_bank
* Program name: Staging SCMS.BANK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (6 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: license_issue_date, settlement_bank_decision_date, settlement_start_date, business_reg_cert_date, custodian_start_date, custodian_cert_date; int sang bigint: last_modified_by.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                              AS id
    , CAST(address AS string)                         AS address
    , CAST(phone AS string)                           AS phone
    , CAST(email AS string)                           AS email
    , CAST(enterprise_code AS string)                 AS enterprise_code
    , CAST(tax_code AS string)                        AS tax_code
    , CAST(created_at AS timestamp)                   AS created_at
    , CAST(created_by AS bigint)                      AS created_by
    , CAST(bank_name AS string)                       AS bank_name
    , CAST(record_status AS bigint)                   AS record_status
    , CAST(last_modified_by AS bigint)                   AS last_modified_by
    , CAST(last_modified_at AS timestamp)             AS last_modified_at
    , CAST(name_en AS string)                         AS name_en
    , CAST(short_name AS string)                      AS short_name
    , CAST(fax AS string)                             AS fax
    , CAST(website AS string)                         AS website
    , CAST(operation_license_number AS string)        AS operation_license_number
    , CAST(license_issue_date AS date)           AS license_issue_date
    , CAST(license_issuer AS string)                  AS license_issuer
    , CAST(charter_capital AS decimal(20,2))          AS charter_capital
    , CAST(category AS int)                           AS category
    , CAST(settlement_bank_decision_number AS string) AS settlement_bank_decision_number
    , CAST(settlement_bank_decision_date AS date) AS settlement_bank_decision_date
    , CAST(settlement_start_date AS date)        AS settlement_start_date
    , CAST(settlement_function_description AS string) AS settlement_function_description
    , CAST(business_reg_cert_number AS string)        AS business_reg_cert_number
    , CAST(business_reg_cert_date AS date)       AS business_reg_cert_date
    , CAST(custodian_start_date AS date)         AS custodian_start_date
    , CAST(custodian_member_cert_number AS string)    AS custodian_member_cert_number
    , CAST(custodian_cert_date AS date)          AS custodian_cert_date
    , CAST(custodian_member_code AS string)           AS custodian_member_code
    , CAST(custodian_function_description AS string)  AS custodian_function_description
    , CAST(attachment_path AS string)                 AS attachment_path
    , CAST(note AS string)                            AS note
    , CAST(input_report_data AS int)                  AS input_report_data
    , CAST(eform_data_json AS string)                 AS eform_data_json
    , CAST(deleted AS int)                            AS deleted
FROM {{ source('source_scms', 'raw_bank') }}