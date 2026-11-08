/*
*--------------------------------------------------------------------*
* Program code: atm_violation_record
* Program name: Atomic Violation Record
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH vi_re AS (
    SELECT
        id
        , inspection_team_id
        , examination_team_id
        , record_date
        , record_type
        , violation_time
        , location
        , source_info
        , recorder_name
        , recorder_title
        , recorder_unit
        , subject_type
        , subject_name
        , subject_id_number
        , subject_dob
        , subject_address
        , subject_legal_rep
        , subject_legal_rep_title
        , subject_email
        , subject_phone
        , status
        , signature_type
        , signed_by
        , signed_at
        , first_signed_by
        , first_signed_at
        , numbered_at
        , sent_at
        , sent_to_inspector
        , forwarded_to_inspection
        , forwarded_at
        , forwarded_by
        , violator_confirmed_by
        , violator_confirmed_receipt_at
        , signed_document_url
        , violator_signed_file_url
    FROM {{ ref('ods_thanhtra_violation_record') }}
),

in_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_inspection_team') }}
),

ex_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_examination_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_RECORD', "vi_re.id") }}     AS violation_record_id
    , CAST(vi_re.id AS string)                                                       AS violation_record_code
    , CAST('THANHTRA_VIOLATION_RECORD' AS string)                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', "in_te.code") }}  AS inspection_team_id
    , CAST(in_te.code AS string)                                       AS inspection_team_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', "ex_te.code") }} AS examination_team_id
    , CAST(ex_te.code AS string)                                      AS examination_team_code
    , CAST(vi_re.record_date AS date)                                                AS record_dt
    , CAST(vi_re.record_type AS string)                                              AS record_tp_code
    , CAST(vi_re.violation_time AS timestamp)                                        AS violation_tms
    , CAST(vi_re.location AS string)                                                 AS location
    , CAST(vi_re.source_info AS string)                                              AS src_info
    , CAST(vi_re.recorder_name AS string)                                            AS recorder_nm
    , CAST(vi_re.recorder_title AS string)                                           AS recorder_title
    , CAST(vi_re.recorder_unit AS string)                                            AS recorder_unit
    , CAST(vi_re.subject_type AS string)                                             AS subject_tp_code
    , CAST(vi_re.subject_name AS string)                                             AS subject_nm
    , CAST(vi_re.subject_id_number AS string)                                        AS subject_id_nbr
    , CAST(vi_re.subject_dob AS date)                                                AS subject_dt_of_birth
    , CAST(vi_re.subject_address AS string)                                          AS subject_adr
    , CAST(vi_re.subject_legal_rep AS string)                                        AS subject_legal_rep
    , CAST(vi_re.subject_legal_rep_title AS string)                                  AS subject_legal_rep_title
    , CAST(vi_re.subject_email AS string)                                            AS subject_email
    , CAST(vi_re.subject_phone AS string)                                            AS subject_phone
    , CAST(vi_re.status AS string)                                                   AS life_cycle_status_code
    , CAST(vi_re.signature_type AS string)                                           AS signature_tp_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "vi_re.signed_by") }}            AS signed_by_officer_id
    , CAST(vi_re.signed_by AS string)                                                AS signed_by_officer_code
    , CAST(vi_re.signed_at AS timestamp)                                             AS signed_tms
    , {{ generate_surrogate_key_bigint('IAM_USERS', "vi_re.first_signed_by") }}      AS first_signed_by_officer_id
    , CAST(vi_re.first_signed_by AS string)                                          AS first_signed_by_officer_code
    , CAST(vi_re.first_signed_at AS timestamp)                                       AS first_signed_tms
    , CAST(vi_re.numbered_at AS timestamp)                                           AS numbered_tms
    , CAST(vi_re.sent_at AS timestamp)                                               AS sent_tms
    , CAST(vi_re.sent_to_inspector AS string)                                        AS sent_to_inspector_indicator
    , CAST(vi_re.forwarded_to_inspection AS string)                                  AS forwarded_to_inspection_indicator
    , CAST(vi_re.forwarded_at AS timestamp)                                          AS forwarded_tms
    , {{ generate_surrogate_key_bigint('IAM_USERS', "vi_re.forwarded_by") }}         AS forwarded_by_officer_id
    , CAST(vi_re.forwarded_by AS string)                                             AS forwarded_by_officer_code
    , CAST(vi_re.violator_confirmed_by AS string)                                    AS violator_confirmed_by
    , CAST(vi_re.violator_confirmed_receipt_at AS timestamp)                         AS violator_confirmed_receipt_tms
    , CAST(vi_re.signed_document_url AS string)                                      AS signed_document_url
    , CAST(vi_re.violator_signed_file_url AS string)                                 AS violator_signed_file_url
FROM vi_re
    LEFT JOIN in_te ON vi_re.INSPECTION_TEAM_ID = in_te.ID
    LEFT JOIN ex_te ON vi_re.EXAMINATION_TEAM_ID = ex_te.ID