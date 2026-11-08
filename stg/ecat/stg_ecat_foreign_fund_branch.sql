/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_foreign_fund_branch
* Program name: Staging ECAT.FOREIGN_FUND_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(name AS string)                    AS name
    , CAST(short_name AS string)              AS short_name
    , CAST(en_name AS string)                 AS en_name
    , CAST(is_branch AS int)                  AS is_branch
    , CAST(parent_name AS string)             AS parent_name
    , CAST(parent_code AS string)             AS parent_code
    , CAST(nat_id AS string)                  AS nat_id
    , CAST(nat_version_id AS string)          AS nat_version_id
    , CAST(parent_address AS string)          AS parent_address
    , CAST(address AS string)                 AS address
    , CAST(phone AS string)                   AS phone
    , CAST(fax AS string)                     AS fax
    , CAST(email AS string)                   AS email
    , CAST(website AS string)                 AS website
    , CAST(reg_no AS string)                  AS reg_no
    , CAST(tax_code AS string)                AS tax_code
    , CAST(license AS string)                 AS license
    , CAST(license_date AS timestamp)         AS license_date
    , CAST(start_date AS timestamp)           AS start_date
    , CAST(end_date AS timestamp)             AS end_date
    , CAST(change_license AS string)          AS change_license
    , CAST(change_license_date AS timestamp)  AS change_license_date
    , CAST(change_note AS string)             AS change_note
    , CAST(status_id AS string)               AS status_id
    , CAST(file_data AS string)               AS file_data
    , CAST(note AS string)                    AS note
    , CAST(status AS int)                     AS status
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(stable_id AS string)               AS stable_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(capital AS bigint)                 AS capital
FROM {{ source('source_ecat', 'raw_foreign_fund_branch') }}