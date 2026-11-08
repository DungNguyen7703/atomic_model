/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sys_user
* Program name: Staging SCMS.SYS_USER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-23
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT.SYS_USER (bang phan quyen, truncate-insert moi 5 phut).
*									BO cac cot bi mat: PASSWORD, DEFAULT_PASSWORD, USER_TOKEN (khong dua
*									mat khau/token vao lakehouse, khong phuc vu phan quyen).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                AS id
    , CAST(user_code AS string)                    AS user_code
    , CAST(username AS string)                     AS username
    , CAST(position_catalog_id AS int)             AS position_catalog_id
    , CAST(full_name AS string)                    AS full_name
    , CAST(email AS string)                        AS email
    , CAST(mobile_phone AS string)                 AS mobile_phone
    , CAST(digital_signature AS int)               AS digital_signature
    , CAST(`member` AS int)                        AS `member`
    , CAST(sc_firm_id AS int)                      AS sc_firm_id
    , CAST(note AS string)                         AS note
    , CAST(avatar AS string)                       AS avatar
    , CAST(created_by AS int)                      AS created_by
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(expiry_date AS timestamp)               AS expiry_date
    , CAST(record_status AS int)                   AS record_status
    , CAST(permissions_json AS string)             AS permissions_json
    , CAST(last_password_change_date AS date)      AS last_password_change_date
    , CAST(legacy_id AS int)                       AS legacy_id
    , CAST(admin AS int)                           AS admin
    , CAST(sso_user_id AS string)                  AS sso_user_id
    , CAST(iam_user_type AS string)                AS iam_user_type
    , CAST(verify_attachment_signature AS int)     AS verify_attachment_signature
FROM {{ source('source_scms', 'raw_sys_user') }}
