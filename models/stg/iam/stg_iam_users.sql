/*
*--------------------------------------------------------------------*
* Program code: stg_iam_users
* Program name: Staging IAM.USERS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                           AS id
    , CAST(full_name AS string)                    AS full_name
    , CAST(username AS string)                     AS username
    , CAST(status AS int)                          AS status
    , CAST(date_of_birth AS date)                  AS date_of_birth
    , CAST(email AS string)                        AS email
    , CAST(phone AS string)                        AS phone
    , CAST(address AS string)                      AS address
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(deleted AS int)                         AS deleted
    , CAST(avatar_path AS string)                  AS avatar_path
    , CAST(key_cloak_id AS string)                 AS key_cloak_id
    , CAST(delete_reason AS string)                AS delete_reason
    , CAST(count_login_false AS int)               AS count_login_false
    , CAST(expire_lock_user AS timestamp)          AS expire_lock_user
    , CAST(last_login AS timestamp)                AS last_login
    , CAST(is_super_admin AS int)                  AS is_super_admin
    , CAST(version AS int)                         AS version
    , CAST(user_type AS int)                       AS user_type
    , CAST(citizen_id_number AS string)            AS citizen_id_number
    , CAST(tax_id_number AS string)                AS tax_id_number
    , CAST(organization_code AS string)            AS organization_code
    , CAST(organization_name AS string)            AS organization_name
    , CAST(gender AS int)                          AS gender
    , CAST(department_id AS string)                AS department_id
    , CAST(position_id AS string)                  AS position_id
    , CAST(representative_name AS string)          AS representative_name
    , CAST(representative_citizen_id AS string)    AS representative_citizen_id
    , CAST(representative_phone AS string)         AS representative_phone
    , CAST(representative_email AS string)         AS representative_email
    , CAST(code AS string)                         AS code
    , CAST(practice_certificate_type_id AS string) AS practice_certificate_type_id
    , CAST(dial_number AS string)                  AS dial_number
    , CAST(office_phone AS string)                 AS office_phone
    , CAST(stock_code AS string)                   AS stock_code
    , CAST(user_sub_type AS string)                AS user_sub_type
    , CAST(status_reason AS string)                AS status_reason
    , CAST(prefix_username AS int)                 AS prefix_username
    , CAST(require_profile_update AS int)          AS require_profile_update
    , CAST(member_id AS string)                    AS member_id
    , CAST(member_name AS string)                  AS member_name
    , CAST(ext_individual_member_id AS string)     AS ext_individual_member_id
    , CAST(ext_individual_member_name AS string)   AS ext_individual_member_name
    , CAST(organization_name_editable AS int)      AS organization_name_editable
    , CAST(tax_id_number_editable AS int)          AS tax_id_number_editable
    , CAST(citizen_id_editable AS int)             AS citizen_id_editable
    , CAST(securities_company_code AS string)      AS securities_company_code
    , CAST(require_update_password AS int)         AS require_update_password
FROM {{ source('source_iam', 'raw_users') }}