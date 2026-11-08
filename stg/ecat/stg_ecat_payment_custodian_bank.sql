/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_payment_custodian_bank
* Program name: Staging ECAT.PAYMENT_CUSTODIAN_BANK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                               AS id
    , CAST(code AS string)                           AS code
    , CAST(name_vn AS string)                        AS name_vn
    , CAST(name_en AS string)                        AS name_en
    , CAST(short_name AS string)                     AS short_name
    , CAST(type AS int)                              AS type
    , CAST(address AS string)                        AS address
    , CAST(phone_number AS string)                   AS phone_number
    , CAST(fax AS string)                            AS fax
    , CAST(email AS string)                          AS email
    , CAST(website AS string)                        AS website
    , CAST(business_license_no AS string)            AS business_license_no
    , CAST(license_issue_date AS timestamp)          AS license_issue_date
    , CAST(license_issuer AS string)                 AS license_issuer
    , CAST(charter_capital AS string)                AS charter_capital
    , CAST(approval_decision_no AS string)           AS approval_decision_no
    , CAST(approval_decision_date AS timestamp)      AS approval_decision_date
    , CAST(operation_start_date AS timestamp)        AS operation_start_date
    , CAST(operation_registration_cert AS string)    AS operation_registration_cert
    , CAST(operation_registration_date AS timestamp) AS operation_registration_date
    , CAST(custody_start_date AS timestamp)          AS custody_start_date
    , CAST(custody_membership_cert AS string)        AS custody_membership_cert
    , CAST(custody_membership_date AS timestamp)     AS custody_membership_date
    , CAST(revocation_decision_no AS string)         AS revocation_decision_no
    , CAST(revocation_decision_date AS timestamp)    AS revocation_decision_date
    , CAST(status AS int)                            AS status
    , CAST(managed_by_company_id AS string)          AS managed_by_company_id
    , CAST(note AS string)                           AS note
    , CAST(active AS int)                            AS active
    , CAST(active_reason AS string)                  AS active_reason
    , CAST(created_at AS timestamp)                  AS created_at
    , CAST(updated_at AS timestamp)                  AS updated_at
    , CAST(created_by_id AS string)                  AS created_by_id
    , CAST(created_by_name AS string)                AS created_by_name
    , CAST(updated_by_id AS string)                  AS updated_by_id
    , CAST(updated_by_name AS string)                AS updated_by_name
    , CAST(effective_start_date AS timestamp)        AS effective_start_date
    , CAST(effective_end_date AS timestamp)          AS effective_end_date
    , CAST(deleted AS int)                           AS deleted
    , CAST(deleted_reason AS string)                 AS deleted_reason
    , CAST(version AS int)                           AS version
    , CAST(old_id AS string)                         AS old_id
    , CAST(stable_id AS string)                      AS stable_id
    , CAST(security_company_version_id AS string)    AS security_company_version_id
FROM {{ source('source_ecat', 'raw_payment_custodian_bank') }}