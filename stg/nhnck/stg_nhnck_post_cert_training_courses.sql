/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_post_cert_training_courses
* Program name: Staging NHNCK.POST_CERT_TRAINING_COURSES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(course_code AS string)   AS course_code
    , CAST(course_name AS string)   AS course_name
    , CAST(class_code AS string)    AS class_code
    , CAST(status AS int)           AS status
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(updated_by AS bigint)    AS updated_by
FROM {{ source('source_nhnck', 'raw_post_cert_training_courses') }}