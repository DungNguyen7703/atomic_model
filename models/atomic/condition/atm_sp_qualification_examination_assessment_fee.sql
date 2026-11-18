/*
*--------------------------------------------------------------------*
* Program code: atm_sp_qualification_examination_assessment_fee
* Program name: Atomic Securities Practitioner Qualification Examination Assessment Fee
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_se_fe AS (
    SELECT
        id
        , exam_session_id
        , certificate_id
        , fee_exam
        , fee_appeal
    FROM {{ ref('ods_nhnck_exam_session_fees') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_EXAM_SESSION_FEES', "ex_se_fe.id") }}            AS sp_qualification_examination_assessment_fee_id
    , CAST(ex_se_fe.id AS string)                                                            AS sp_qualification_examination_assessment_fee_code
    , CAST('NHNCK_EXAM_SESSION_FEES' AS string)                                              AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_EXAM_SESSIONS', "ex_se_fe.exam_session_id") }} AS sp_qualification_examination_assessment_id
    , CAST(ex_se_fe.exam_session_id AS string)                                               AS sp_qualification_examination_assessment_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "ex_se_fe.certificate_id") }}   AS sp_license_certificate_type_id
    , CAST(ex_se_fe.certificate_id AS string)                                                AS sp_license_certificate_type_code
    , CAST(ex_se_fe.fee_exam AS decimal(23,2))                                               AS examination_fee_amt
    , CAST(ex_se_fe.fee_appeal AS decimal(23,2))                                             AS appeal_fee_amt
FROM ex_se_fe