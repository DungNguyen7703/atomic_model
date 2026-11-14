<<<<<<< HEAD
/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_users
* Program name: Staging NHNCK.USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (9 cot); kieu date sang timestamp (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(unit_id AS bigint)                AS unit_id
    , CAST(department_id AS bigint)          AS department_id
    , CAST(position_id AS bigint)            AS position_id
    , CAST(username AS string)               AS username
    , CAST(password AS string)               AS password
    , CAST(full_name AS string)              AS full_name
    , CAST(email AS string)                  AS email
    , CAST(phone_number AS string)           AS phone_number
    , CAST(gender AS int)                    AS gender
    , CAST(ldap AS string)                   AS ldap
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(created_by AS bigint)             AS created_by
    , CAST(status AS bigint)                 AS status
    , CAST(type AS bigint)                   AS type
    , CAST(updated_by AS bigint)             AS updated_by
    , CAST(updated_password_at AS timestamp) AS updated_password_at
    , CAST(professional_id AS bigint)        AS professional_id
    , CAST(identity_number AS string)        AS identity_number
    , CAST(sso_user_id AS string)            AS sso_user_id
=======
/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_users
* Program name: Staging NHNCK.USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(unit_id AS bigint)           AS unit_id
    , CAST(department_id AS bigint)     AS department_id
    , CAST(position_id AS bigint)       AS position_id
    , CAST(username AS string)          AS username
    , CAST(password AS string)          AS password
    , CAST(full_name AS string)         AS full_name
    , CAST(email AS string)             AS email
    , CAST(phone_number AS string)      AS phone_number
    , CAST(gender AS int)               AS gender
    , CAST(ldap AS string)              AS ldap
    , CAST(updated_at AS date)          AS updated_at
    , CAST(created_at AS date)          AS created_at
    , CAST(created_by AS bigint)        AS created_by
    , CAST(status AS bigint)            AS status
    , CAST(type AS bigint)              AS type
    , CAST(updated_by AS bigint)        AS updated_by
    , CAST(updated_password_at AS date) AS updated_password_at
    , CAST(professional_id AS bigint)   AS professional_id
    , CAST(identity_number AS string)   AS identity_number
    , CAST(sso_user_id AS string)       AS sso_user_id
>>>>>>> 16e7f257572ea37da39d62b83c82c5e752ece640
FROM {{ source('source_nhnck', 'raw_users') }}