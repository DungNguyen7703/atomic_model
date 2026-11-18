/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_professional_histories
* Program name: ODS NHNCK.PROFESSIONAL_HISTORIES
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
    , professional_id
    , change_date
    , national
    , religion
    , hometown
    , status_work
    , reason_update
    , status_account
FROM {{ ref('stg_nhnck_professional_histories') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')