/*
*--------------------------------------------------------------------*
* Program code: atm_sp_qualification_examination_assessment
* Program name: Atomic Securities Practitioner Qualification Examination Assessment
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_se AS (
    SELECT
        code
        , name
        , year
        , session_
        , organizing_unit
        , application_start_date
        , application_end_date
        , exam_start_date
        , exam_end_date
        , noti_date
        , exam_locations
        , submission_methods
        , file_path
        , decision_id
        , bank_id
        , bank_account_number
        , bank_account_name
    FROM {{ ref('ods_nhnck_exam_sessions') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_EXAM_SESSIONS', "ex_se.code") }}      AS sp_qualification_examination_assessment_id
    , CAST(ex_se.code AS string)                                                  AS sp_qualification_examination_assessment_code
    , CAST('NHNCK_EXAM_SESSIONS' AS string)                                       AS src_stm_code
    , CAST(ex_se.name AS string)                                                  AS assessment_nm
    , CAST(ex_se.year AS int)                                                     AS rpt_year
    , CAST(ex_se.session_ AS int)                                                 AS examination_session_nbr
    , CAST(ex_se.organizing_unit AS string)                                       AS organizing_unit_nm
    , CAST(ex_se.application_start_date AS string)                                AS application_registration_start_dt
    , CAST(ex_se.application_end_date AS string)                                  AS application_registration_end_dt
    , CAST(ex_se.exam_start_date AS string)                                       AS examination_start_dt
    , CAST(ex_se.exam_end_date AS string)                                         AS examination_end_dt
    , CAST(ex_se.noti_date AS string)                                             AS result_notification_dt
    , CAST(ex_se.exam_locations AS string)                                        AS examination_locations
    , CAST(ex_se.submission_methods AS string)                                    AS submission_methods
    , CAST(ex_se.file_path AS string)                                             AS notification_file_path
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ex_se.decision_id") }} AS sp_license_decision_document_id
    , CAST(ex_se.decision_id AS string)                                           AS sp_license_decision_document_code
    , CAST(ex_se.bank_id AS string)                                               AS bank_code
    , CAST(ex_se.bank_account_number AS string)                                   AS bank_account_nbr
    , CAST(ex_se.bank_account_name AS string)                                     AS bank_account_nm
FROM ex_se