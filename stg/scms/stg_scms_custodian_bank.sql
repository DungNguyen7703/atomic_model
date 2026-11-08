/*
*--------------------------------------------------------------------*
* Program code: stg_scms_custodian_bank
* Program name: Staging SCMS.CUSTODIAN_BANK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                               AS id
    , CAST(name_vi AS string)                          AS name_vi
    , CAST(name_en AS string)                          AS name_en
    , CAST(short_name AS string)                       AS short_name
    , CAST(address AS string)                          AS address
    , CAST(phone AS string)                            AS phone
    , CAST(email AS string)                            AS email
    , CAST(fax AS string)                              AS fax
    , CAST(website AS string)                          AS website
    , CAST(establishment_license AS string)            AS establishment_license
    , CAST(license_issue_date AS timestamp)            AS license_issue_date
    , CAST(issue_place AS string)                      AS issue_place
    , CAST(charter_capital AS string)                  AS charter_capital
    , CAST(bank_category AS int)                       AS bank_category
    , CAST(approval_decision_number AS string)         AS approval_decision_number
    , CAST(approval_decision_date AS timestamp)        AS approval_decision_date
    , CAST(approval_operation_start_date AS timestamp) AS approval_operation_start_date
    , CAST(business_reg_cert_number AS string)         AS business_reg_cert_number
    , CAST(business_reg_cert_date AS timestamp)        AS business_reg_cert_date
    , CAST(custodian_start_date AS timestamp)          AS custodian_start_date
    , CAST(custodian_member_cert_number AS string)     AS custodian_member_cert_number
    , CAST(custodian_cert_date AS timestamp)           AS custodian_cert_date
    , CAST(liquidation_decision AS string)             AS liquidation_decision
    , CAST(liquidation_decision_date AS timestamp)     AS liquidation_decision_date
    , CAST(note AS string)                             AS note
    , CAST(created_by AS bigint)                       AS created_by
    , CAST(created_at AS timestamp)                    AS created_at
    , CAST(last_modified_by AS bigint)                 AS last_modified_by
    , CAST(last_modified_at AS timestamp)              AS last_modified_at
    , CAST(record_status AS int)                       AS record_status
    , CAST(sc_firm_info_id AS bigint)                  AS sc_firm_info_id
FROM {{ source('source_scms', 'raw_custodian_bank') }}