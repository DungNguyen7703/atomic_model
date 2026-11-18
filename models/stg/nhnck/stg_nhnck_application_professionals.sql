/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_professionals
* Program name: Staging NHNCK.APPLICATION_PROFESSIONALS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (18 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(application_id AS bigint)           AS application_id
    , CAST(professional_id AS bigint)          AS professional_id
    , CAST(organization_id AS bigint)          AS organization_id
    , CAST(nationality_id AS bigint)           AS nationality_id
    , CAST(education_level_id AS bigint)       AS education_level_id
    , CAST(registration_type AS bigint)        AS registration_type
    , CAST(username AS string)                 AS username
    , CAST(password AS string)                 AS password
    , CAST(full_name AS string)                AS full_name
    , CAST(first_name AS string)               AS first_name
    , CAST(avatar AS string)                   AS avatar
    , CAST(birth_date AS date)                 AS birth_date
    , CAST(birth_year AS string)               AS birth_year
    , CAST(gender AS bigint)                   AS gender
    , CAST(permanent_country_id AS bigint)     AS permanent_country_id
    , CAST(permanent_province_id AS bigint)    AS permanent_province_id
    , CAST(permanent_district_id AS bigint)    AS permanent_district_id
    , CAST(permanent_address AS string)        AS permanent_address
    , CAST(current_country_id AS bigint)       AS current_country_id
    , CAST(current_province_id AS bigint)      AS current_province_id
    , CAST(current_district_id AS bigint)      AS current_district_id
    , CAST(place_of_birth AS string)           AS place_of_birth
    , CAST(address AS string)                  AS address
    , CAST(identity_number AS string)          AS identity_number
    , CAST(identity_issue_date AS date)        AS identity_issue_date
    , CAST(identity_issue_place AS string)     AS identity_issue_place
    , CAST(phone_number AS string)             AS phone_number
    , CAST(mobile_number AS string)            AS mobile_number
    , CAST(email AS string)                    AS email
    , CAST(workplace AS string)                AS workplace
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(created_by AS bigint)               AS created_by
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(updated_by AS bigint)               AS updated_by
    , CAST(status AS bigint)                   AS status
    , CAST(identity_type AS bigint)            AS identity_type
    , CAST(position AS string)                 AS position
    , CAST(department AS string)               AS department
    , CAST(previous_identity_number AS string) AS previous_identity_number
FROM {{ source('source_nhnck', 'raw_application_professionals') }}