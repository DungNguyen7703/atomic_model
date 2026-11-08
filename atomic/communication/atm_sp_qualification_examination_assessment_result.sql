/*
*--------------------------------------------------------------------*
* Program code: atm_sp_qualification_examination_assessment_result
* Program name: Atomic Securities Practitioner Qualification Examination Assessment Result
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_de AS (
    SELECT
        id
        , exam_session_id
        , professional_id
        , certificate_id
        , application_id
        , sequence_number
        , exam_number
        , law_score
        , law_result
        , specialization_score
        , specialization_result
        , result
        , note
    FROM {{ ref('ods_nhnck_exam_details') }}
),

ex_se AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_nhnck_exam_sessions') }}
),

cert AS (
    SELECT
        id
        , certificate_code
    FROM {{ ref('ods_nhnck_certificates') }}
),

appl AS (
    SELECT
        id
        , application_code
    FROM {{ ref('ods_nhnck_applications') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_EXAM_DETAILS', "ex_de.id") }}                 AS sp_qualification_examination_assessment_result_id
    , CAST(ex_de.id AS string)                                                            AS sp_qualification_examination_assessment_result_code
    , CAST('NHNCK_EXAM_DETAILS' AS string)                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_EXAM_SESSIONS', "ex_se.code") }}            AS sp_qualification_examination_assessment_id
    , CAST(ex_de.exam_session_id AS string)                                               AS sp_qualification_examination_assessment_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "ex_de.professional_id") }} AS sp_id
    , CAST(ex_de.professional_id AS string)                                               AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert.certificate_code") }}  AS sp_license_certificate_tp_id
    , CAST(ex_de.certificate_id AS string)                                                AS sp_license_certificate_tp_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.application_code") }}  AS sp_license_application_id
    , CAST(ex_de.application_id AS string)                                                AS sp_license_application_code
    , CAST(ex_de.sequence_number AS int)                                                  AS sequence_nbr
    , CAST(ex_de.exam_number AS string)                                                   AS exam_nbr
    , CAST(ex_de.law_score AS int)                                                        AS law_score
    , CAST(ex_de.law_result AS string)                                                    AS law_result_code
    , CAST(ex_de.specialization_score AS int)                                             AS specialization_score
    , CAST(ex_de.specialization_result AS string)                                         AS specialization_result_code
    , CAST(ex_de.result AS string)                                                        AS overall_result_code
    , CAST(ex_de.note AS string)                                                          AS examination_note
FROM ex_de
    LEFT JOIN ex_se ON ex_de.EXAM_SESSION_ID = ex_se.ID
    LEFT JOIN cert ON ex_de.CERTIFICATE_ID = cert.ID
    LEFT JOIN appl ON ex_de.APPLICATION_ID = appl.ID