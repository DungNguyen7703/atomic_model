/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_foreign_fund_branch_new
* Program name: Staging ECAT.FOREIGN_FUND_BRANCH_NEW
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu timestamp sang date (7 cot); kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                         AS id
    , CAST(id_sync AS string)                                    AS id_sync
    , CAST(company_name AS string)                               AS company_name
    , CAST(parent_company_name AS string)                        AS parent_company_name
    , CAST(head_office_address AS string)                        AS head_office_address
    , CAST(parent_registration_no AS string)                     AS parent_registration_no
    , CAST(country_id AS string)                                 AS country_id
    , CAST(country_name AS string)                               AS country_name
    , CAST(parent_license_no AS string)                          AS parent_license_no
    , CAST(parent_license_issue_date AS date)               AS parent_license_issue_date
    , CAST(parent_license_issuer AS string)                      AS parent_license_issuer
    , CAST(official_operation_date AS date)                 AS official_operation_date
    , CAST(parent_fax AS string)                                 AS parent_fax
    , CAST(parent_phone AS string)                               AS parent_phone
    , CAST(charter_capital AS decimal(18,2))                     AS charter_capital
    , CAST(registration_certificate_no AS string)                AS registration_certificate_no
    , CAST(branch_name AS string)                                AS branch_name
    , CAST(branch_english_name AS string)                        AS branch_english_name
    , CAST(branch_short_name AS string)                          AS branch_short_name
    , CAST(branch_address AS string)                             AS branch_address
    , CAST(establishment_decision AS string)                     AS establishment_decision
    , CAST(decision_issue_date AS date)                     AS decision_issue_date
    , CAST(tax_code AS string)                                   AS tax_code
    , CAST(branch_phone AS string)                               AS branch_phone
    , CAST(branch_fax AS string)                                 AS branch_fax
    , CAST(email AS string)                                      AS email
    , CAST(website AS string)                                    AS website
    , CAST(activity_content AS string)                           AS activity_content
    , CAST(operation_date AS date)                          AS operation_date
    , CAST(expiration_date AS date)                         AS expiration_date
    , CAST(status_id AS string)                                  AS status_id
    , CAST(status_name AS string)                                AS status_name
    , CAST(note AS string)                                       AS note
    , CAST(attachments AS string)                                AS attachments
    , CAST(head_representative_name AS string)                   AS head_representative_name
    , CAST(head_representative_gender AS int)                    AS head_representative_gender
    , CAST(head_representative_nationality AS string)            AS head_representative_nationality
    , CAST(head_representative_document_number AS string)        AS head_representative_document_number
    , CAST(head_representative_document_issue_date AS date) AS head_representative_document_issue_date
    , CAST(head_representative_address AS string)                AS head_representative_address
    , CAST(case_name AS string)                                  AS case_name
    , CAST(latest_certificate_no AS string)                      AS latest_certificate_no
    , CAST(approval_date AS date)                           AS approval_date
    , CAST(change_reason AS string)                              AS change_reason
    , CAST(change_content AS string)                             AS change_content
    , CAST(created_by AS string)                                 AS created_by
    , CAST(created_date AS timestamp)                            AS created_date
    , CAST(last_updated_by AS string)                            AS last_updated_by
    , CAST(last_updated_date AS timestamp)                       AS last_updated_date
    , CAST(active AS int)                                        AS active
    , CAST(active_reason AS string)                              AS active_reason
    , CAST(deleted AS int)                                       AS deleted
    , CAST(deleted_reason AS string)                             AS deleted_reason
    , CAST(version AS int)                                  AS version
    , CAST(effective_start_date AS timestamp)                    AS effective_start_date
    , CAST(effective_end_date AS timestamp)                      AS effective_end_date
    , CAST(old_id AS string)                                     AS old_id
    , CAST(stable_id AS string)                                  AS stable_id
    , CAST(created_at AS timestamp)                              AS created_at
    , CAST(updated_at AS timestamp)                              AS updated_at
    , CAST(created_by_id AS string)                              AS created_by_id
    , CAST(created_by_name AS string)                            AS created_by_name
    , CAST(updated_by_id AS string)                              AS updated_by_id
    , CAST(updated_by_name AS string)                            AS updated_by_name
FROM {{ source('source_ecat', 'raw_foreign_fund_branch_new') }}