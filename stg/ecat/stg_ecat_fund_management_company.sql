/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_fund_management_company
* Program name: Staging ECAT.FUND_MANAGEMENT_COMPANY
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
    , CAST(name_vi AS string)                        AS name_vi
    , CAST(name_en AS string)                        AS name_en
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
    , CAST(ceo_position AS string)                   AS ceo_position
    , CAST(business_license_number AS string)        AS business_license_number
    , CAST(business_license_date AS timestamp)       AS business_license_date
    , CAST(business_license_place AS string)         AS business_license_place
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
FROM {{ source('source_ecat', 'raw_fund_management_company') }}