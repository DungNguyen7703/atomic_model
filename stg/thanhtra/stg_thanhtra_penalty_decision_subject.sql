/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_decision_subject
* Program name: Staging THANHTRA.PENALTY_DECISION_SUBJECT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(penalty_decision_id AS string)          AS penalty_decision_id
    , CAST(subject_type AS string)                 AS subject_type
    , CAST(subject_name AS string)                 AS subject_name
    , CAST(subject_id_number AS string)            AS subject_id_number
    , CAST(subject_dob AS date)                    AS subject_dob
    , CAST(subject_address AS string)              AS subject_address
    , CAST(subject_legal_rep AS string)            AS subject_legal_rep
    , CAST(subject_legal_rep_title AS string)      AS subject_legal_rep_title
    , CAST(total_fine_amount AS decimal(19,4))     AS total_fine_amount
    , CAST(paid_amount AS decimal(19,4))           AS paid_amount
    , CAST(coerced_amount AS decimal(19,4))        AS coerced_amount
    , CAST(payment_received_date AS date)          AS payment_received_date
    , CAST(compliance_status AS string)            AS compliance_status
    , CAST(enforcement_progress AS string)         AS enforcement_progress
    , CAST(note AS string)                         AS note
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
    , CAST(payment_proof_url AS string)            AS payment_proof_url
    , CAST(payment_proof_uploaded_at AS timestamp) AS payment_proof_uploaded_at
    , CAST(subject_tax_code AS string)             AS subject_tax_code
    , CAST(subject_email AS string)                AS subject_email
    , CAST(subject_phone AS string)                AS subject_phone
    , CAST(email_sent_at AS timestamp)             AS email_sent_at
    , CAST(sms_sent_at AS timestamp)               AS sms_sent_at
    , CAST(violation_record_id AS string)          AS violation_record_id
    , CAST(receipt_status AS string)               AS receipt_status
    , CAST(viewed_at AS timestamp)                 AS viewed_at
    , CAST(downloaded_at AS timestamp)             AS downloaded_at
    , CAST(confirmed_at AS timestamp)              AS confirmed_at
    , CAST(received_at AS timestamp)               AS received_at
FROM {{ source('source_thanhtra', 'raw_penalty_decision_subject') }}