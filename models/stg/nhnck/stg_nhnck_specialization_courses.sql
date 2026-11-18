/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_specialization_courses
* Program name: Staging NHNCK.SPECIALIZATION_COURSES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot); doi thu tu cot.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(specialization_id AS bigint) AS specialization_id
    , CAST(academic_year AS bigint)     AS academic_year
    , CAST(course_code AS string)       AS course_code
    , CAST(course_name AS string)       AS course_name
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(created_by AS bigint)        AS created_by
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(updated_by AS bigint)        AS updated_by
    , CAST(status AS bigint)            AS status
    , CAST(exam_date_from AS date)      AS exam_date_from
    , CAST(address AS string)           AS address
    , CAST(province_id AS bigint)       AS province_id
    , CAST(exam_date_to AS date)        AS exam_date_to
FROM {{ source('source_nhnck', 'raw_specialization_courses') }}