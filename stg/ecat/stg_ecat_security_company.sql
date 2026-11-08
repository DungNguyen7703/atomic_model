/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_security_company
* Program name: Staging ECAT.SECURITY_COMPANY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                AS id
    , CAST(code AS string)                            AS code
    , CAST(security_code AS string)                   AS security_code
    , CAST(company_name AS string)                    AS company_name
    , CAST(company_name_en AS string)                 AS company_name_en
    , CAST(short_name AS string)                      AS short_name
    , CAST(enterprise_type_id AS string)              AS enterprise_type_id
    , CAST(status AS int)                             AS status
    , CAST(effective_date AS timestamp)               AS effective_date
    , CAST(expire_date AS timestamp)                  AS expire_date
    , CAST(modified_date AS timestamp)                AS modified_date
    , CAST(address AS string)                         AS address
    , CAST(province_new_id AS string)                 AS province_new_id
    , CAST(district_old_id AS string)                 AS district_old_id
    , CAST(ward_new_id AS string)                     AS ward_new_id
    , CAST(phone_number AS string)                    AS phone_number
    , CAST(fax AS string)                             AS fax
    , CAST(email AS string)                           AS email
    , CAST(website AS string)                         AS website
    , CAST(represent AS string)                       AS represent
    , CAST(manager AS string)                         AS manager
    , CAST(gpkd_place AS string)                      AS gpkd_place
    , CAST(gpkd_number AS string)                     AS gpkd_number
    , CAST(gpkd_date AS timestamp)                    AS gpkd_date
    , CAST(securities_business_activities AS string)  AS securities_business_activities
    , CAST(listed_flag AS int)                        AS listed_flag
    , CAST(listed_date AS timestamp)                  AS listed_date
    , CAST(market AS string)                          AS market
    , CAST(public_company_flag AS int)                AS public_company_flag
    , CAST(public_company_register_date AS timestamp) AS public_company_register_date
    , CAST(public_company_end_date AS timestamp)      AS public_company_end_date
    , CAST(disclosure_officer AS string)              AS disclosure_officer
    , CAST(disclosure_email AS string)                AS disclosure_email
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
    , CAST(stable_id AS string)                       AS stable_id
    , CAST(enterprise_type_version_id AS string)      AS enterprise_type_version_id
    , CAST(province_new_version_id AS string)         AS province_new_version_id
    , CAST(district_old_version_id AS string)         AS district_old_version_id
    , CAST(ward_new_version_id AS string)             AS ward_new_version_id
    , CAST(charter_capital AS bigint)                 AS charter_capital
FROM {{ source('source_ecat', 'raw_security_company') }}