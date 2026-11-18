/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_identity_info_c06s
* Program name: ODS NHNCK.IDENTITY_INFO_C06S
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
    , first_name
    , birth_date
    , birth_year
    , identity_number
    , gender
    , national
    , religion
    , permanent_country_code
    , permanent_province_code
    , permanent_district_code
    , permanent_detail
    , current_country_code
    , current_province_code
    , current_district_code
    , current_detail
    , country_code
    , place_of_birth
    , hometown
    , father_full_name
    , father_country_code
    , father_identity_number
    , father_identity_number_old
    , mother_full_name
    , mother_country_code
    , mother_identity_number
    , mother_identity_number_old
    , couple_full_name
    , couple_country_code
    , couple_identity_number
    , couple_identity_number_old
    , created_at
    , updated_at
    , created_by
    , updated_by
    , user_updated_id
    , place_of_birth_country_code
    , place_of_birth_province_code
    , place_of_birth_district_code
FROM {{ ref('stg_nhnck_identity_info_c06s') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')