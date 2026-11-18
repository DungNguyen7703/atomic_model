/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_application_re_exam_request
* Program name: Atomic Securities Practitioner License Application Re-Exam Request
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ap_re_ex AS (
    SELECT
        id
        , application_id
        , exam_detail_id
        , re_application_id
    FROM {{ ref('ods_nhnck_application_re_exams') }}
),

appl AS (
    SELECT
        id
        , application_code
    FROM {{ ref('ods_nhnck_applications') }}
),

appl_re AS (
    SELECT
        id
        , application_code
    FROM {{ ref('ods_nhnck_applications') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_APPLICATION_RE_EXAMS', "ap_re_ex.id") }}       AS sp_license_application_re_exam_request_id
    , CAST(ap_re_ex.id AS string)                                                          AS sp_license_application_re_exam_request_code
    , CAST('NHNCK_APPLICATION_RE_EXAMS' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.application_code") }}   AS sp_license_application_id
    , CAST(ap_re_ex.application_id AS string)                                              AS sp_license_application_code
    , {{ generate_surrogate_key_bigint('NHNCK_EXAM_DETAILS', "ap_re_ex.exam_detail_id") }} AS sp_qualification_examination_assessment_result_id
    , CAST(ap_re_ex.exam_detail_id AS string)                                              AS sp_qualification_examination_assessment_result_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl_re.application_code") }} AS re_exam_sp_license_application_id
    , CAST(ap_re_ex.re_application_id AS string)                                           AS re_exam_sp_license_application_code
FROM ap_re_ex
    LEFT JOIN appl ON ap_re_ex.APPLICATION_ID = appl.ID
    LEFT JOIN appl_re ON ap_re_ex.RE_APPLICATION_ID = appl_re.ID