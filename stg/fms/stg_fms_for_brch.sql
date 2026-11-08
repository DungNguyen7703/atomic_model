/*
*--------------------------------------------------------------------*
* Program code: stg_fms_for_brch
* Program name: Staging FMS.FOR_BRCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(status_id)                     AS status_id
    , HEX(nat_id)                        AS nat_id
    , CAST(branch_flag AS int)           AS branch_flag
    , CAST(item_name AS string)          AS item_name
    , CAST(en_name AS string)            AS en_name
    , CAST(short_name AS string)         AS short_name
    , CAST(address AS string)            AS address
    , CAST(license AS string)            AS license
    , CAST(license_date AS date)         AS license_date
    , CAST(phone AS string)              AS phone
    , CAST(fax AS string)                AS fax
    , CAST(email AS string)              AS email
    , CAST(website AS string)            AS website
    , CAST(start_date AS date)           AS start_date
    , CAST(end_date AS date)             AS end_date
    , CAST(parent_name AS string)        AS parent_name
    , CAST(parent_code AS string)        AS parent_code
    , CAST(parent_address AS string)     AS parent_address
    , CAST(change_license AS string)     AS change_license
    , CAST(change_license_date AS date)  AS change_license_date
    , CAST(change_note AS string)        AS change_note
    , CAST(file_data AS string)          AS file_data
    , CAST(note AS string)               AS note
    , CAST(deleted AS int)               AS deleted
    , CAST(reg_no AS string)             AS reg_no
    , CAST(tax_code AS string)           AS tax_code
    , CAST(capital AS decimal(18,2))     AS capital
    , CAST(data_migration AS int)        AS data_migration
    , CAST(id_db_old AS string)          AS id_db_old
    , HEX(event_type_id)                 AS event_type_id
    , CAST(parent_issue_place AS string) AS parent_issue_place
    , CAST(parent_issue_date AS date)    AS parent_issue_date
    , CAST(activity_period AS string)    AS activity_period
    , CAST(province_id AS string)        AS province_id
    , CAST(ward_id AS string)            AS ward_id
FROM {{ source('source_fms', 'raw_for_brch') }}