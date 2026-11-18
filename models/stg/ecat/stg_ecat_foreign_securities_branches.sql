/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_foreign_securities_branches
* Program name: Staging ECAT.FOREIGN_SECURITIES_BRANCHES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                              AS id
    , CAST(id_sync AS bigint)                         AS id_sync
    , CAST(stable_id AS string)                       AS stable_id
    , CAST(branch_name AS string)                     AS branch_name
    , CAST(branch_english_name AS string)             AS branch_english_name
    , CAST(branch_short_name AS string)               AS branch_short_name
    , CAST(branch_address AS string)                  AS branch_address
    , CAST(phone AS string)                           AS phone
    , CAST(fax AS string)                             AS fax
    , CAST(email AS string)                           AS email
    , CAST(tax_code AS string)                        AS tax_code
    , CAST(enterprise_code AS string)                 AS enterprise_code
    , CAST(establishment_license_no AS string)        AS establishment_license_no
    , CAST(establishment_license_date AS timestamp)   AS establishment_license_date
    , CAST(operation_certificate_no AS string)        AS operation_certificate_no
    , CAST(operation_certificate_date AS timestamp)   AS operation_certificate_date
    , CAST(official_operation_date AS timestamp)      AS official_operation_date
    , CAST(service_id AS bigint)                      AS service_id
    , CAST(granted_capital AS decimal(20,0))          AS granted_capital
    , CAST(fiscal_year_end_date AS string)            AS fiscal_year_end_date
    , CAST(financial_statement_type AS string)        AS financial_statement_type
    , CAST(status_id AS string)                       AS status_id
    , CAST(status_name AS string)                     AS status_name
    , CAST(parent_company_name AS string)             AS parent_company_name
    , CAST(parent_operation_license_no AS string)     AS parent_operation_license_no
    , CAST(parent_license_issue_date AS timestamp)    AS parent_license_issue_date
    , CAST(parent_head_office_address AS string)      AS parent_head_office_address
    , CAST(country_id AS string)                      AS country_id
    , CAST(country_name AS string)                    AS country_name
    , CAST(representative_name AS string)             AS representative_name
    , CAST(representative_nationality_id AS string)   AS representative_nationality_id
    , CAST(representative_nationality_name AS string) AS representative_nationality_name
    , CAST(representative_date_of_birth AS timestamp) AS representative_date_of_birth
    , CAST(representative_document_no AS string)      AS representative_document_no
    , CAST(representative_document_date AS timestamp) AS representative_document_date
    , CAST(representative_document_place AS string)   AS representative_document_place
    , CAST(file_path AS string)                       AS file_path
    , CAST(file_name AS string)                       AS file_name
    , CAST(note AS string)                            AS note
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
    , CAST(service_name AS string)                    AS service_name
    , CAST(country_code AS string)                    AS country_code
FROM {{ source('source_ecat', 'raw_foreign_securities_branches') }}