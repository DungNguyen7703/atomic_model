/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_payment_custodian_bank_new
* Program name: Staging ECAT.PAYMENT_CUSTODIAN_BANK_NEW
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu timestamp sang date (4 cot); kieu decimal(38,10) sang int (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                               AS id
    , CAST(code AS string)                             AS code
    , CAST(name_vn AS string)                          AS name_vn
    , CAST(name_en AS string)                          AS name_en
    , CAST(short_name AS string)                       AS short_name
    , CAST(enterprise_code AS string)                  AS enterprise_code
    , CAST(establishment_license AS string)            AS establishment_license
    , CAST(tax_code AS string)                         AS tax_code
    , CAST(address AS string)                          AS address
    , CAST(phone_number AS string)                     AS phone_number
    , CAST(fax AS string)                              AS fax
    , CAST(email AS string)                            AS email
    , CAST(website AS string)                          AS website
    , CAST(license_issue_date AS date)                 AS license_issue_date
    , CAST(license_issuer AS string)                   AS license_issuer
    , CAST(charter_capital AS int)                     AS charter_capital
    , CAST(bank_category AS int)                       AS bank_category
    , CAST(input_report_data AS int)                   AS input_report_data
    , CAST(payment_decision_number AS string)          AS payment_decision_number
    , CAST(payment_decision_date AS date)              AS payment_decision_date
    , CAST(payment_start_date AS date)                 AS payment_start_date
    , CAST(payment_function_description AS string)     AS payment_function_description
    , CAST(business_reg_cert_number AS string)         AS business_reg_cert_number
    , CAST(business_reg_cert_date AS date)             AS business_reg_cert_date
    , CAST(business_operation_start_date AS timestamp) AS business_operation_start_date
    , CAST(custodian_member_cert_number AS string)     AS custodian_member_cert_number
    , CAST(custodian_cert_date AS timestamp)           AS custodian_cert_date
    , CAST(custodian_member_code AS string)            AS custodian_member_code
    , CAST(custodian_function_description AS string)   AS custodian_function_description
    , CAST(note AS string)                             AS note
    , CAST(stable_id AS string)                        AS stable_id
    , CAST(deleted AS int)                             AS deleted
    , CAST(deleted_reason AS string)                   AS deleted_reason
    , CAST(version AS int)                             AS version
    , CAST(effective_start_date AS timestamp)          AS effective_start_date
    , CAST(effective_end_date AS timestamp)            AS effective_end_date
    , CAST(old_id AS string)                           AS old_id
    , CAST(created_at AS timestamp)                    AS created_at
    , CAST(updated_at AS timestamp)                    AS updated_at
    , CAST(created_by_id AS string)                    AS created_by_id
    , CAST(created_by_name AS string)                  AS created_by_name
    , CAST(updated_by_id AS string)                    AS updated_by_id
    , CAST(updated_by_name AS string)                  AS updated_by_name
    , CAST(id_sync AS string)                          AS id_sync
    , CAST(active AS string)                           AS active
    , CAST(status_id AS string)                        AS status_id
    , CAST(attachment_path AS string)                  AS attachment_path
FROM {{ source('source_ecat', 'raw_payment_custodian_bank_new') }}