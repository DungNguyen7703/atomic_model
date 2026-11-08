/*
*--------------------------------------------------------------------*
* Program code: atm_sp_post_certification_training_course
* Program name: Atomic Securities Practitioner Post Certification Training Course
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH po_ce_tr_co AS (
    SELECT
        course_code
        , course_name
        , class_code
    FROM {{ ref('ods_nhnck_post_cert_training_courses') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_POST_CERT_TRAINING_COURSES', "po_ce_tr_co.course_code") }} AS sp_post_certification_training_course_id
    , CAST(po_ce_tr_co.course_code AS string)                                                          AS sp_post_certification_training_course_code
    , CAST('NHNCK_POST_CERT_TRAINING_COURSES' AS string)                                               AS src_stm_code
    , CAST(po_ce_tr_co.course_name AS string)                                                          AS training_course_nm
    , CAST(po_ce_tr_co.class_code AS string)                                                           AS training_class_code
FROM po_ce_tr_co