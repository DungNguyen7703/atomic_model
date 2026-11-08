/*
*--------------------------------------------------------------------*
* Program code: atm_pd_subject
* Program name: Atomic Penalty Decision Subject
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        id
        , penalty_decision_id
        , subject_type
        , subject_name
        , subject_id_number
        , subject_address
        , subject_tax_code
        , subject_dob
        , subject_legal_rep
        , subject_legal_rep_title
        , total_fine_amount
        , paid_amount
        , coerced_amount
        , payment_received_date
        , compliance_status
        , payment_proof_url
        , payment_proof_uploaded_at
        , subject_email
        , subject_phone
        , email_sent_at
        , sms_sent_at
        , violation_record_id
        , receipt_status
        , viewed_at
        , downloaded_at
        , confirmed_at
        , received_at
    FROM {{ ref('ods_thanhtra_penalty_decision_subject') }}
),

vi_re AS (
    SELECT
        id
    FROM {{ ref('ods_thanhtra_violation_record') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT', "pe_de_su.id") }}            AS pd_subject_id
    , CAST(pe_de_su.id AS string)                                                                      AS pd_subject_code
    , CAST('THANHTRA_PENALTY_DECISION_SUBJECT' AS string)                                              AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION', "pe_de_su.penalty_decision_id") }} AS pd_id
    , CAST(pe_de_su.penalty_decision_id AS string)                                                     AS pd_code
    , CAST(pe_de_su.subject_type AS string)                                                            AS subject_tp_code
    , CAST(pe_de_su.subject_name AS string)                                                            AS subject_nm
    , CAST(pe_de_su.subject_id_number AS string)                                                       AS subject_id_nbr
    , CAST(pe_de_su.subject_address AS string)                                                         AS subject_adr
    , CAST(pe_de_su.subject_tax_code AS string)                                                        AS subject_tax_code
    , CAST(pe_de_su.subject_dob AS date)                                                               AS subject_dt_of_birth
    , CAST(pe_de_su.subject_legal_rep AS string)                                                       AS subject_legal_rep
    , CAST(pe_de_su.subject_legal_rep_title AS string)                                                 AS subject_legal_rep_title
    , CAST(pe_de_su.total_fine_amount AS decimal(23,2))                                                AS total_fine_amt
    , CAST(pe_de_su.paid_amount AS decimal(23,2))                                                      AS paid_amt
    , CAST(pe_de_su.coerced_amount AS decimal(23,2))                                                   AS coerced_amt
    , CAST(pe_de_su.payment_received_date AS date)                                                     AS payment_received_dt
    , CAST(pe_de_su.compliance_status AS string)                                                       AS compliance_status_code
    , CAST(pe_de_su.payment_proof_url AS string)                                                       AS payment_proof_url
    , CAST(pe_de_su.payment_proof_uploaded_at AS timestamp)                                            AS payment_proof_uploaded_tms
    , CAST(pe_de_su.subject_email AS string)                                                           AS subject_email
    , CAST(pe_de_su.subject_phone AS string)                                                           AS subject_phone
    , CAST(pe_de_su.email_sent_at AS timestamp)                                                        AS email_sent_tms
    , CAST(pe_de_su.sms_sent_at AS timestamp)                                                          AS sms_sent_tms
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_RECORD', "pe_de_su.violation_record_id") }} AS violation_record_id
    , CAST(vi_re.id AS string)                                                                         AS violation_record_code
    , CAST(pe_de_su.receipt_status AS string)                                                          AS receipt_status_code
    , CAST(pe_de_su.viewed_at AS timestamp)                                                            AS viewed_tms
    , CAST(pe_de_su.downloaded_at AS timestamp)                                                        AS downloaded_tms
    , CAST(pe_de_su.confirmed_at AS timestamp)                                                         AS confirmed_tms
    , CAST(pe_de_su.received_at AS timestamp)                                                          AS received_tms
FROM pe_de_su
    LEFT JOIN vi_re ON pe_de_su.Id = vi_re.Id