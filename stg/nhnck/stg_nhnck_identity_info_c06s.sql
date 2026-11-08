/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_identity_info_c06s
* Program name: Staging NHNCK.IDENTITY_INFO_C06S
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                             AS id
    , CAST(full_name AS string)                    AS full_name
    , CAST(first_name AS string)                   AS first_name
    , CAST(birth_date AS date)                     AS birth_date
    , CAST(birth_year AS string)                   AS birth_year
    , CAST(identity_number AS string)              AS identity_number
    , CAST(gender AS string)                       AS gender
    , CAST(national AS string)                     AS national
    , CAST(religion AS string)                     AS religion
    , CAST(permanent_country_code AS string)       AS permanent_country_code
    , CAST(permanent_province_code AS string)      AS permanent_province_code
    , CAST(permanent_district_code AS string)      AS permanent_district_code
    , CAST(permanent_detail AS string)             AS permanent_detail
    , CAST(current_country_code AS string)         AS current_country_code
    , CAST(current_province_code AS string)        AS current_province_code
    , CAST(current_district_code AS string)        AS current_district_code
    , CAST(current_detail AS string)               AS current_detail
    , CAST(country_code AS string)                 AS country_code
    , CAST(place_of_birth AS string)               AS place_of_birth
    , CAST(hometown AS string)                     AS hometown
    , CAST(father_full_name AS string)             AS father_full_name
    , CAST(father_country_code AS string)          AS father_country_code
    , CAST(father_identity_number AS string)       AS father_identity_number
    , CAST(father_identity_number_old AS string)   AS father_identity_number_old
    , CAST(mother_full_name AS string)             AS mother_full_name
    , CAST(mother_country_code AS string)          AS mother_country_code
    , CAST(mother_identity_number AS string)       AS mother_identity_number
    , CAST(mother_identity_number_old AS string)   AS mother_identity_number_old
    , CAST(couple_full_name AS string)             AS couple_full_name
    , CAST(couple_country_code AS string)          AS couple_country_code
    , CAST(couple_identity_number AS string)       AS couple_identity_number
    , CAST(couple_identity_number_old AS string)   AS couple_identity_number_old
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by AS bigint)                   AS created_by
    , CAST(updated_by AS bigint)                   AS updated_by
    , CAST(user_updated_id AS bigint)              AS user_updated_id
    , CAST(place_of_birth_country_code AS string)  AS place_of_birth_country_code
    , CAST(place_of_birth_province_code AS string) AS place_of_birth_province_code
    , CAST(place_of_birth_district_code AS string) AS place_of_birth_district_code
FROM {{ source('source_nhnck', 'raw_identity_info_c06s') }}