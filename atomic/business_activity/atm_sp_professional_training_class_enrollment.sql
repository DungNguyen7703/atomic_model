/*
*--------------------------------------------------------------------*
* Program code: atm_sp_professional_training_class_enrollment
* Program name: Atomic Securities Practitioner Professional Training Class Enrollment
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sp_co_de AS (
    SELECT
        id
        , specialization_course_id
        , professional_id
        , specialization_id
        , exam_number
        , full_name
        , birth_date
        , place_of_birth
        , permanent_country_id
        , permanent_province_id
        , permanent_district_id
        , identity_type
        , identity_number
        , identity_issue_date
        , identity_issue_place
        , exam_score
        , result
        , description
        , note
        , assignee_id
    FROM {{ ref('ods_nhnck_specialization_course_details') }}
),

sp_co AS (
    SELECT
        id
        , course_code
    FROM {{ ref('ods_nhnck_specialization_courses') }}
),

coun AS (
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
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_SPECIALIZATION_COURSE_DETAILS', "sp_co_de.id") }}  AS sp_professional_training_class_enrollment_id
    , CAST(sp_co_de.id AS string)                                                              AS sp_professional_training_class_enrollment_code
    , CAST('NHNCK_SPECIALIZATION_COURSE_DETAILS' AS string)                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_SPECIALIZATION_COURSES', "sp_co.course_code") }} AS sp_professional_training_class_id
    , CAST(sp_co_de.specialization_course_id AS string)                                        AS sp_professional_training_class_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "sp_co_de.professional_id") }}   AS sp_id
    , CAST(sp_co_de.professional_id AS string)                                                 AS sp_code
    , CAST(sp_co_de.specialization_id AS string)                                               AS specialization_tp_code
    , CAST(sp_co_de.exam_number AS string)                                                     AS exam_nbr
    , CAST(sp_co_de.full_name AS string)                                                       AS practitioner_nm_at_enrollment
    , CAST(sp_co_de.birth_date AS date)                                                        AS practitioner_birth_dt_at_enrollment
    , CAST(sp_co_de.place_of_birth AS string)                                                  AS place_of_birth
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun.country_code") }}                 AS permanent_residence_country_id
    , CAST(sp_co_de.permanent_country_id AS string)                                            AS permanent_residence_country_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.province_code") }}           AS permanent_residence_province_id
    , CAST(sp_co_de.permanent_province_id AS string)                                           AS permanent_residence_province_code
    , {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "dist.district_code") }}           AS permanent_residence_district_id
    , CAST(sp_co_de.permanent_district_id AS string)                                           AS permanent_residence_district_code
    , CAST(sp_co_de.identity_type AS string)                                                   AS practitioner_identity_tp_code_at_enrollment
    , CAST(sp_co_de.identity_number AS string)                                                 AS practitioner_identity_nbr_at_enrollment
    , CAST(sp_co_de.identity_issue_date AS date)                                               AS practitioner_identity_issue_dt_at_enrollment
    , CAST(sp_co_de.identity_issue_place AS string)                                            AS practitioner_identity_issue_place_at_enrollment
    , CAST(sp_co_de.exam_score AS decimal(5,2))                                                AS exam_score
    , CAST(sp_co_de.result AS string)                                                          AS training_result_code
    , CAST(sp_co_de.description AS string)                                                     AS description
    , CAST(sp_co_de.note AS string)                                                            AS note
    , {{ generate_surrogate_key_bigint('IAM_USERS', "sp_co_de.assignee_id") }}                 AS assignee_officer_id
    , CAST(sp_co_de.assignee_id AS string)                                                     AS assignee_officer_code
FROM sp_co_de
    LEFT JOIN sp_co ON sp_co_de.SPECIALIZATION_COURSE_ID = sp_co.ID
    LEFT JOIN coun ON sp_co_de.PERMANENT_COUNTRY_ID = coun.ID
    LEFT JOIN prov ON sp_co_de.PERMANENT_PROVINCE_ID = prov.ID
    LEFT JOIN dist ON sp_co_de.PERMANENT_DISTRICT_ID = dist.ID