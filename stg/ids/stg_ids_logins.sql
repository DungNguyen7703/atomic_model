/*
*--------------------------------------------------------------------*
* Program code: stg_ids_logins
* Program name: Staging IDS.LOGINS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(login_name AS string)            AS login_name
    , CAST(full_name AS string)             AS full_name
    , CAST(birth_date AS date)              AS birth_date
    , CAST(email AS string)                 AS email
    , CAST(address AS string)               AS address
    , CAST(tel AS string)                   AS tel
    , CAST(fax AS string)                   AS fax
    , CAST(gender_cd AS int)                AS gender_cd
    , CAST(dept_cd AS string)               AS dept_cd
    , CAST(login_type AS int)               AS login_type
    , CAST(object_type AS int)              AS object_type
    , CAST(company_profile_id AS bigint)    AS company_profile_id
    , CAST(id_sync AS string)               AS id_sync
    , CAST(active_flg AS int)               AS active_flg
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS date)            AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS date)            AS updated_date
    , CAST(is_super_admin AS decimal(38,0)) AS is_super_admin
FROM {{ source('source_ids', 'raw_logins') }}