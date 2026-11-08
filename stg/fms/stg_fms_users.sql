/*
*--------------------------------------------------------------------*
* Program code: stg_fms_users
* Program name: Staging FMS.USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                AS id
    , CAST(date_created AS date)           AS date_created
    , CAST(created_by AS string)           AS created_by
    , CAST(date_modified AS date)          AS date_modified
    , CAST(modify_by AS string)            AS modify_by
    , CAST(user_name AS string)            AS user_name
    , CAST(display_name AS string)         AS display_name
    , CAST(password AS string)             AS password
    , CAST(record_status AS int)           AS record_status
    , CAST(date_logined AS date)           AS date_logined
    , HEX(sec_id)                          AS sec_id
    , CAST(lev AS decimal(38,0))           AS lev
    , CAST(record_type AS decimal(38,0))   AS record_type
    , HEX(job_id)                          AS job_id
    , CAST(job_name AS string)             AS job_name
    , CAST(org_password AS string)         AS org_password
    , CAST(deleted AS int)                 AS deleted
    , CAST(certificate_flag AS int)        AS certificate_flag
    , CAST(email AS string)                AS email
    , CAST(date_change_password AS date)   AS date_change_password
    , HEX(bkm_id)                          AS bkm_id
    , HEX(fr_br_id)                        AS fr_br_id
    , CAST(data_migration AS int)          AS data_migration
    , CAST(check_digital_signature AS int) AS check_digital_signature
FROM {{ source('source_fms', 'raw_users') }}