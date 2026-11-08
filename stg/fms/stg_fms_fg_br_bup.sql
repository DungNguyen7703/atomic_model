/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fg_br_bup
* Program name: Staging FMS.FG_BR_BUP
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
    , HEX(fg_his_id)                     AS fg_his_id
    , CAST(branch_flag AS int)           AS branch_flag
    , CAST(deleted AS int)               AS deleted
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
    , CAST(str_busis AS string)          AS str_busis
    , CAST(str_staff AS string)          AS str_staff
    , CAST(str_national AS string)       AS str_national
    , CAST(str_status AS string)         AS str_status
    , CAST(created_by AS string)         AS created_by
    , CAST(date_created AS date)         AS date_created
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , CAST(parent_issue_place AS string) AS parent_issue_place
    , CAST(parent_issue_date AS date)    AS parent_issue_date
    , CAST(activity_period AS string)    AS activity_period
FROM {{ source('source_fms', 'raw_fg_br_bup') }}