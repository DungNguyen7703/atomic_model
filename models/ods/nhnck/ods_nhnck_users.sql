/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_users
* Program name: ODS NHNCK.USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , unit_id
    , department_id
    , position_id
    , username
    , password
    , full_name
    , email
    , phone_number
    , gender
    , ldap
    , updated_at
    , created_at
    , created_by
    , status
    , type
    , updated_by
    , updated_password_at
    , professional_id
    , identity_number
    , sso_user_id
FROM {{ ref('stg_nhnck_users') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')