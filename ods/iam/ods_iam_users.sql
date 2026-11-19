/*
*--------------------------------------------------------------------*
* Program code: ods_iam_users
* Program name: ODS IAM.USERS
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
    , full_name
    , username
    , status
    , date_of_birth
    , email
    , phone
    , address
    , created_at
    , updated_at
    , created_by_id
    , updated_by_id
    , created_by_name
    , updated_by_name
    , deleted
    , avatar_path
    , key_cloak_id
    , delete_reason
    , count_login_false
    , expire_lock_user
    , last_login
    , is_super_admin
    , version
    , user_type
    , citizen_id_number
    , tax_id_number
    , organization_code
    , organization_name
    , gender
    , department_id
    , position_id
    , representative_name
    , representative_citizen_id
    , representative_phone
    , representative_email
    , code
    , practice_certificate_type_id
    , dial_number
    , office_phone
    , stock_code
    , user_sub_type
    , status_reason
    , prefix_username
    , require_profile_update
    , member_id
    , member_name
    , ext_individual_member_id
    , ext_individual_member_name
    , organization_name_editable
    , tax_id_number_editable
    , citizen_id_editable
    , securities_company_code
    , require_update_password
FROM {{ ref('stg_iam_users') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')