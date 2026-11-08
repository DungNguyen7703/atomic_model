/*
*--------------------------------------------------------------------*
* Program code: stg_ids_users
* Program name: Staging IDS.USERS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                               AS id
    , CAST(user_name AS string)             AS user_name
    , CAST(password AS string)              AS password
    , CAST(full_name AS string)             AS full_name
    , CAST(birth_date AS date)              AS birth_date
    , CAST(gender_cd AS string)             AS gender_cd
    , CAST(address AS string)               AS address
    , CAST(phone_no AS string)              AS phone_no
    , CAST(fax_no AS string)                AS fax_no
    , CAST(email AS string)                 AS email
    , CAST(identity AS string)              AS identity
    , CAST(identity_type_cd AS string)      AS identity_type_cd
    , CAST(identity_issued_date AS date)    AS identity_issued_date
    , CAST(identity_issued_place AS string) AS identity_issued_place
    , CAST(status AS int)                   AS status
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS timestamp)       AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS timestamp)       AS updated_date
    , CAST(department_id AS decimal(19,0))  AS department_id
FROM {{ source('source_ids', 'raw_users') }}