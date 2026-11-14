/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_foreign_branch
* Program name: Staging ECAT.FOREIGN_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang string (1 cot); them cot tax_code, enterprise_code, official_operation_date, operation_duration_year, expiration_date, operation_scope, phone_number, fax_number, email, country_id, country_version_id, country_name, nationality_name, representative_document_number, representative_document_issue_date, representative_address, create_by, created_date, last_updated_by, last_updated_date, id_sync, operation_status_id, position_title, date_of_birth, issue_place, country_code; bo cot parent_license_issuer, branch_license_issuer, document_type_id, document_type_version_id, document_number, decision_date, valid_application_date, change_reason, document_type.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(parent_company_name AS string)          AS parent_company_name
    , CAST(parent_company_address AS string)       AS parent_company_address
    , CAST(parent_business_license AS string)      AS parent_business_license
    , CAST(parent_license_issue_date AS timestamp) AS parent_license_issue_date
    , CAST(branch_name AS string)                  AS branch_name
    , CAST(branch_address AS string)               AS branch_address
    , CAST(branch_license AS string)               AS branch_license
    , CAST(branch_license_issue_date AS timestamp) AS branch_license_issue_date
    , CAST(head_representative AS string)          AS head_representative
    , CAST(nationality_id AS string)               AS nationality_id
    , CAST(nationality_version_id AS string)       AS nationality_version_id
    , CAST(attachment_file AS string)              AS attachment_file
    , CAST(note AS string)                         AS note
    , CAST(status AS int)                          AS status
    , CAST(active_reason AS string)                AS active_reason
    , CAST(deleted AS int)                         AS deleted
    , CAST(deleted_reason AS string)               AS deleted_reason
    , CAST(version AS int)                         AS version
    , CAST(effective_start_date AS timestamp)      AS effective_start_date
    , CAST(effective_end_date AS timestamp)        AS effective_end_date
    , CAST(old_id AS string)                       AS old_id
    , CAST(stable_id AS string)                    AS stable_id
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(tax_code AS string)                              AS tax_code
    , CAST(enterprise_code AS string)                       AS enterprise_code
    , CAST(official_operation_date AS timestamp)            AS official_operation_date
    , CAST(operation_duration_year AS bigint)               AS operation_duration_year
    , CAST(expiration_date AS timestamp)                    AS expiration_date
    , CAST(operation_scope AS string)                       AS operation_scope
    , CAST(phone_number AS string)                          AS phone_number
    , CAST(fax_number AS string)                            AS fax_number
    , CAST(email AS string)                                 AS email
    , CAST(country_id AS string)                            AS country_id
    , CAST(country_version_id AS string)                    AS country_version_id
    , CAST(country_name AS string)                          AS country_name
    , CAST(nationality_name AS string)                      AS nationality_name
    , CAST(representative_document_number AS string)        AS representative_document_number
    , CAST(representative_document_issue_date AS timestamp) AS representative_document_issue_date
    , CAST(representative_address AS string)                AS representative_address
    , CAST(create_by AS string)                             AS create_by
    , CAST(created_date AS timestamp)                       AS created_date
    , CAST(last_updated_by AS string)                       AS last_updated_by
    , CAST(last_updated_date AS timestamp)                  AS last_updated_date
    , CAST(id_sync AS bigint)                               AS id_sync
    , CAST(operation_status_id AS string)                   AS operation_status_id
    , CAST(position_title AS string)                        AS position_title
    , CAST(date_of_birth AS timestamp)                      AS date_of_birth
    , CAST(issue_place AS string)                           AS issue_place
    , CAST(operation_status AS string)                      AS operation_status
    , CAST(country_code AS string)                          AS country_code
FROM {{ source('source_ecat', 'raw_foreign_branch') }}