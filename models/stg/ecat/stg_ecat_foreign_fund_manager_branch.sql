/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_foreign_fund_manager_branch
* Program name: Staging ECAT.FOREIGN_FUND_MANAGER_BRANCH
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu timestamp sang date (2 cot); kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(stable_id AS string)                   AS stable_id
    , CAST(branch_name AS string)                 AS branch_name
    , CAST(branch_english_name AS string)         AS branch_english_name
    , CAST(branch_short_name AS string)           AS branch_short_name
    , CAST(address AS string)                     AS address
    , CAST(license_number AS string)              AS license_number
    , CAST(license_issue_date AS date)            AS license_issue_date
    , CAST(reg_no AS string)                      AS reg_no
    , CAST(tax_code AS string)                    AS tax_code
    , CAST(capital AS decimal(20,2))              AS capital
    , CAST(phone AS string)                       AS phone
    , CAST(fax AS string)                         AS fax
    , CAST(email AS string)                       AS email
    , CAST(website AS string)                     AS website
    , CAST(activity_content AS string)            AS activity_content
    , CAST(operation_term AS string)              AS operation_term
    , CAST(status_id AS string)                   AS status_id
    , CAST(status_name AS string)                 AS status_name
    , CAST(branch_director AS string)             AS branch_director
    , CAST(parent_company_name AS string)         AS parent_company_name
    , CAST(parent_head_office_address AS string)  AS parent_head_office_address
    , CAST(parent_business_reg_no AS string)      AS parent_business_reg_no
    , CAST(parent_registration_place AS string)   AS parent_registration_place
    , CAST(parent_registration_date AS date)      AS parent_registration_date
    , CAST(country_id AS string)                  AS country_id
    , CAST(country_name AS string)                AS country_name
    , CAST(event_type_id AS string)               AS event_type_id
    , CAST(event_type_name AS string)             AS event_type_name
    , CAST(latest_amendment_license_no AS string) AS latest_amendment_license_no
    , CAST(approval_date AS timestamp)            AS approval_date
    , CAST(amendment_reason AS string)            AS amendment_reason
    , CAST(file_data AS string)                   AS file_data
    , CAST(note AS string)                        AS note
    , CAST(active AS int)                         AS active
    , CAST(active_reason AS string)               AS active_reason
    , CAST(deleted AS int)                        AS deleted
    , CAST(deleted_reason AS string)              AS deleted_reason
    , CAST(version AS int)                        AS version
    , CAST(effective_start_date AS timestamp)     AS effective_start_date
    , CAST(effective_end_date AS timestamp)       AS effective_end_date
    , CAST(old_id AS string)                      AS old_id
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(id_sync AS string)                     AS id_sync
FROM {{ source('source_ecat', 'raw_foreign_fund_manager_branch') }}