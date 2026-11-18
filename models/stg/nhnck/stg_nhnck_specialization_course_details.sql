/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_specialization_course_details
* Program name: Staging NHNCK.SPECIALIZATION_COURSE_DETAILS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (13 cot); kieu date sang timestamp (2 cot); doi kieu cot exam_score.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(specialization_course_id AS bigint) AS specialization_course_id
    , CAST(professional_id AS bigint)          AS professional_id
    , CAST(exam_number AS string)              AS exam_number
    , CAST(full_name AS string)                AS full_name
    , CAST(birth_date AS date)                 AS birth_date
    , CAST(permanent_country_id AS bigint)     AS permanent_country_id
    , CAST(permanent_province_id AS bigint)    AS permanent_province_id
    , CAST(permanent_district_id AS bigint)    AS permanent_district_id
    , CAST(place_of_birth AS string)           AS place_of_birth
    , CAST(identity_type AS bigint)            AS identity_type
    , CAST(identity_number AS string)          AS identity_number
    , CAST(identity_issue_date AS date)        AS identity_issue_date
    , CAST(identity_issue_place AS string)     AS identity_issue_place
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(created_by AS bigint)               AS created_by
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(updated_by AS bigint)               AS updated_by
    , CAST(description AS string)              AS description
    , CAST(exam_score AS decimal(38,10))       AS exam_score
    , CAST(result AS bigint)                   AS result
    , CAST(status AS bigint)                   AS status
    , CAST(note AS string)                     AS note
    , CAST(specialization_id AS bigint)        AS specialization_id
    , CAST(assignee_id AS bigint)              AS assignee_id
FROM {{ source('source_nhnck', 'raw_specialization_course_details') }}