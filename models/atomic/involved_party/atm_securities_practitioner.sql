/*
*--------------------------------------------------------------------*
* Program code: atm_securities_practitioner
* Program name: Atomic Securities Practitioner
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pro AS (
    SELECT
        id
        , full_name
        , first_name
        , birth_date
        , birth_year
        , gender
        , education_level_id
        , registration_type
        , status_work
        , status_account
        , organization_id
        , nationality_id
        , workplace
        , position
        , department
        , previous_identity_number
        , previous_identity_issue_date
        , previous_identity_issue_place
        , hometown
        , national
        , religion
        , place_of_birth
        , avatar
        , place_of_birth_country_id
        , place_of_birth_province_id
        , place_of_birth_district_id
        , sso_synced
        , sso_user_id
        , status
        , previous_status_work
        , suspension_start_date
        , suspension_end_date
        , suspension_file_path
    FROM {{ ref('ods_nhnck_professionals') }}
),

org AS (
    SELECT
        id
        , organization_code
    FROM {{ ref('ods_nhnck_organizations') }}
),

coun AS (
    SELECT
        id
        , country_code
    FROM {{ ref('ods_nhnck_countries') }}
),

coun_2 AS (
    SELECT
        id
        , country_code
    FROM {{ ref('ods_nhnck_countries') }}
),

prov AS (
    SELECT
        id
        , province_code
    FROM {{ ref('ods_nhnck_provinces') }}
),

dist AS (
    SELECT
        id
        , district_code
    FROM {{ ref('ods_nhnck_districts') }}
),

user AS (
    SELECT
        id
        , username
    FROM {{ ref('ods_nhnck_users') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "pro.id") }}                  AS sp_id
    , CAST(pro.id AS string)                                                              AS sp_code
    , CAST('NHNCK_PROFESSIONALS' AS string)                                               AS src_stm_code
    , CAST(pro.full_name AS string)                                                       AS full_nm
    , CAST(pro.first_name AS string)                                                      AS given_nm
    , CAST(pro.birth_date AS date)                                                        AS birth_dt
    , CAST(pro.birth_year AS string)                                                      AS birth_year
    , CAST(pro.gender AS string)                                                          AS gender_code
    , CAST(pro.education_level_id AS string)                                              AS education_level_code
    , CAST(pro.registration_type AS string)                                               AS practitioner_registration_tp_code
    , CAST(pro.status_work AS string)                                                     AS practice_status_code
    , CAST(pro.status_account AS string)                                                  AS account_status_code
    , {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "org.organization_code") }} AS securities_organization_reference_id
    , CAST(org.organization_code AS string)                                               AS securities_organization_reference_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun.country_code") }}            AS nationality_id
    , CAST(coun.country_code AS string)                                                   AS nationality_code
    , CAST(pro.workplace AS string)                                                       AS workplace_nm
    , CAST(pro.position AS string)                                                        AS position_nm
    , CAST(pro.department AS string)                                                      AS department_nm
    , CAST(pro.previous_identity_number AS string)                                        AS previous_identity_nbr
    , CAST(pro.previous_identity_issue_date AS date)                                      AS previous_identity_issue_dt
    , CAST(pro.previous_identity_issue_place AS string)                                   AS previous_identity_issue_place
    , CAST(pro.hometown AS string)                                                        AS hometown
    , CAST(pro.national AS string)                                                        AS ethnicity_nm
    , CAST(pro.religion AS string)                                                        AS religion_nm
    , CAST(pro.place_of_birth AS string)                                                  AS place_of_birth_description
    , CAST(pro.avatar AS string)                                                          AS avatar_file_path
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun_2.country_code") }}          AS place_of_birth_country_id
    , CAST(coun_2.country_code AS string)                                                 AS place_of_birth_country_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.province_code") }}      AS place_of_birth_province_id
    , CAST(prov.province_code AS string)                                                  AS place_of_birth_province_code
    , {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "dist.district_code") }}      AS place_of_birth_district_id
    , CAST(dist.district_code AS string)                                                  AS place_of_birth_district_code
    , CAST(pro.sso_synced AS string)                                                      AS sso_sync_status_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "user.username") }}                   AS identity_and_access_management_user_id
    , CAST(user.username AS string)                                                       AS identity_and_access_management_user_code
    , CAST(pro.status AS string)                                                          AS status_code
    , CAST(pro.previous_status_work AS string)                                            AS previous_practice_status_code
    , CAST(pro.suspension_start_date AS date)                                             AS suspension_start_dt
    , CAST(pro.suspension_end_date AS date)                                               AS suspension_end_dt
    , CAST(pro.suspension_file_path AS string)                                            AS suspension_file_path
FROM pro
    LEFT JOIN org ON pro.ORGANIZATION_ID = org.ID
    LEFT JOIN coun ON pro.NATIONALITY_ID = coun.ID
    LEFT JOIN coun_2 ON pro.PLACE_OF_BIRTH_COUNTRY_ID = coun_2.ID
    LEFT JOIN prov ON pro.PLACE_OF_BIRTH_PROVINCE_ID = prov.ID
    LEFT JOIN dist ON pro.PLACE_OF_BIRTH_DISTRICT_ID = dist.ID
    LEFT JOIN user ON pro.SSO_USER_ID = user.ID