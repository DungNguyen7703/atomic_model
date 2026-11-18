/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_professionals
* Program name: ODS NHNCK.PROFESSIONALS
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
    , organization_id
    , nationality_id
    , education_level_id
    , registration_type
    , username
    , password
    , full_name
    , first_name
    , avatar
    , birth_date
    , birth_year
    , gender
    , permanent_country_id
    , permanent_province_id
    , permanent_district_id
    , permanent_address
    , current_country_id
    , current_province_id
    , current_district_id
    , place_of_birth
    , address
    , identity_number
    , identity_issue_date
    , identity_issue_place
    , phone_number
    , mobile_number
    , email
    , workplace
    , created_at
    , created_by
    , updated_at
    , updated_by
    , status
    , identity_type
    , position
    , department
    , previous_identity_number
    , hometown
    , national
    , religion
    , status_work
    , status_account
    , place_of_birth_country_id
    , place_of_birth_province_id
    , place_of_birth_district_id
    , sso_user_id
    , sso_synced
    , passport_number
    , passport_issue_place
    , passport_issue_date
    , previous_identity_issue_place
    , previous_identity_issue_date
    , previous_status_work
    , suspension_start_date
    , suspension_end_date
    , suspension_file_path
FROM {{ ref('stg_nhnck_professionals') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')