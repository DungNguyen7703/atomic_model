/*
*--------------------------------------------------------------------*
* Program code: atm_sp_post_certification_training_result
* Program name: Atomic Securities Practitioner Post Certification Training Result
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH po_ce_tr_re AS (
    SELECT
        id
        , professional_id
        , training_course_id
        , start_date
        , end_date
        , training_hours
        , result_status
        , classification_result
        , note
    FROM {{ ref('ods_nhnck_post_cert_training_results') }}
),

po_ce_tr_co AS (
    SELECT
        id
        , course_code
    FROM {{ ref('ods_nhnck_post_cert_training_courses') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_POST_CERT_TRAINING_RESULTS', "po_ce_tr_re.id") }}            AS sp_post_certification_training_result_id
    , CAST(po_ce_tr_re.id AS string)                                                                     AS sp_post_certification_training_result_code
    , CAST('NHNCK_POST_CERT_TRAINING_RESULTS' AS string)                                                 AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "po_ce_tr_re.professional_id") }}          AS sp_id
    , CAST(po_ce_tr_re.professional_id AS string)                                                        AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_POST_CERT_TRAINING_COURSES', "po_ce_tr_co.course_code") }} AS sp_post_certification_training_course_id
    , CAST(po_ce_tr_re.training_course_id AS string)                                                     AS sp_post_certification_training_course_code
    , CAST(po_ce_tr_re.start_date AS date)                                                               AS training_start_dt
    , CAST(po_ce_tr_re.end_date AS date)                                                                 AS training_end_dt
    , CAST(po_ce_tr_re.training_hours AS int)                                                            AS training_hours
    , CAST(po_ce_tr_re.result_status AS string)                                                          AS training_result_status_code
    , CAST(po_ce_tr_re.classification_result AS string)                                                  AS training_cl_result_code
    , CAST(po_ce_tr_re.note AS string)                                                                   AS note
FROM po_ce_tr_re
    LEFT JOIN po_ce_tr_co ON po_ce_tr_re.TRAINING_COURSE_ID = po_ce_tr_co.ID