/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_fund_management_company
* Program name: Staging ECAT.FUND_MANAGEMENT_COMPANY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: them cot company_name, company_english_name, chief_executive_officer, securities_business_license_number, securities_business_license_date, adjustment_license_numbers, enterprise_type_name, official_operation_date, operation_status_name, operation_status, business_registration_number, note, file_data, id_sync; bo cot name_vi, name_en, ceo_position, business_license_number, business_license_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                               AS id
    , CAST(code AS string)                           AS code
    , CAST(company_name AS string)                        AS company_name
    , CAST(company_english_name AS string)                AS company_english_name
    , CAST(short_name AS string)                     AS short_name
    , CAST(short_name_en AS string)                  AS short_name_en
    , CAST(business_skill AS string)                 AS business_skill
    , CAST(enterprise_type_id AS string)             AS enterprise_type_id
    , CAST(effective_status_start_date AS timestamp) AS effective_status_start_date
    , CAST(effective_status_end_date AS timestamp)   AS effective_status_end_date
    , CAST(effective_status AS int)                  AS effective_status
    , CAST(address AS string)                        AS address
    , CAST(phone AS string)                          AS phone
    , CAST(fax AS string)                            AS fax
    , CAST(email AS string)                          AS email
    , CAST(website AS string)                        AS website
    , CAST(province_new_id AS string)                AS province_new_id
    , CAST(ward_new_id AS string)                    AS ward_new_id
    , CAST(district_old_id AS string)                AS district_old_id
    , CAST(legal_representative AS string)           AS legal_representative
    , CAST(chief_executive_officer AS string)             AS chief_executive_officer
    , CAST(securities_business_license_number AS string)  AS securities_business_license_number
    , CAST(securities_business_license_date AS timestamp) AS securities_business_license_date
    , CAST(business_license_place AS string)         AS business_license_place
    , CAST(adjustment_license_numbers AS string)          AS adjustment_license_numbers
    , CAST(issue_document AS string)                 AS issue_document
    , CAST(issue_date AS timestamp)                  AS issue_date
    , CAST(financial_id AS string)                   AS financial_id
    , CAST(active AS int)                            AS active
    , CAST(active_reason AS string)                  AS active_reason
    , CAST(deleted AS int)                           AS deleted
    , CAST(deleted_reason AS string)                 AS deleted_reason
    , CAST(version AS int)                           AS version
    , CAST(effective_start_date AS timestamp)        AS effective_start_date
    , CAST(effective_end_date AS timestamp)          AS effective_end_date
    , CAST(old_id AS string)                         AS old_id
    , CAST(created_at AS timestamp)                  AS created_at
    , CAST(updated_at AS timestamp)                  AS updated_at
    , CAST(created_by_id AS string)                  AS created_by_id
    , CAST(created_by_name AS string)                AS created_by_name
    , CAST(updated_by_id AS string)                  AS updated_by_id
    , CAST(updated_by_name AS string)                AS updated_by_name
    , CAST(stable_id AS string)                      AS stable_id
    , CAST(enterprise_type_version_id AS string)     AS enterprise_type_version_id
    , CAST(province_new_version_id AS string)        AS province_new_version_id
    , CAST(ward_new_version_id AS string)            AS ward_new_version_id
    , CAST(district_old_version_id AS string)        AS district_old_version_id
    , CAST(total_shares AS bigint)                   AS total_shares
    , CAST(charter_capital AS bigint)                AS charter_capital
    , CAST(par_value AS bigint)                      AS par_value
    , CAST(enterprise_type_name AS string)                AS enterprise_type_name
    , CAST(official_operation_date AS timestamp)          AS official_operation_date
    , CAST(operation_status_name AS string)               AS operation_status_name
    , CAST(operation_status AS string)                    AS operation_status
    , CAST(business_registration_number AS string)        AS business_registration_number
    , CAST(note AS string)                                AS note
    , CAST(file_data AS string)                           AS file_data
    , CAST(id_sync AS string)                             AS id_sync
FROM {{ source('source_ecat', 'raw_fund_management_company') }}