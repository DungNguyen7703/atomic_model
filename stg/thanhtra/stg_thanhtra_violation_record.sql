/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_record
* Program name: Staging THANHTRA.VIOLATION_RECORD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_VIOLATION_RECORD.yaml] them cot email_sent_at, sms_sent_at (cuoi danh sach)
* 2026-11-03		nghia.le			[DDL moi THANHTRA.VIOLATION_RECORD] them cot no_longer_violation, no_longer_violation_note, no_longer_violation_at, no_longer_violation_by, violation_time_from, violation_time_to (cuoi danh sach)
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                 AS id
    , CAST(record_number AS string)                    AS record_number
    , CAST(record_date AS date)                        AS record_date
    , CAST(record_type AS string)                      AS record_type
    , CAST(inspection_team_id AS string)               AS inspection_team_id
    , CAST(examination_team_id AS string)              AS examination_team_id
    , CAST(violation_time AS timestamp)                AS violation_time
    , CAST(location AS string)                         AS location
    , CAST(source_info AS string)                      AS source_info
    , CAST(recorder_name AS string)                    AS recorder_name
    , CAST(recorder_title AS string)                   AS recorder_title
    , CAST(recorder_unit AS string)                    AS recorder_unit
    , CAST(subject_type AS string)                     AS subject_type
    , CAST(subject_name AS string)                     AS subject_name
    , CAST(subject_id_number AS string)                AS subject_id_number
    , CAST(subject_dob AS date)                        AS subject_dob
    , CAST(subject_address AS string)                  AS subject_address
    , CAST(subject_legal_rep AS string)                AS subject_legal_rep
    , CAST(subject_legal_rep_title AS string)          AS subject_legal_rep_title
    , CAST(subject_email AS string)                    AS subject_email
    , CAST(subject_phone AS string)                    AS subject_phone
    , CAST(status AS string)                           AS status
    , CAST(signed_by AS string)                        AS signed_by
    , CAST(signed_at AS timestamp)                     AS signed_at
    , CAST(numbered_at AS timestamp)                   AS numbered_at
    , CAST(sent_at AS timestamp)                       AS sent_at
    , CAST(sent_to_inspector AS int)                   AS sent_to_inspector
    , CAST(created_at AS date)                         AS created_at
    , CAST(last_modified_at AS date)                   AS last_modified_at
    , CAST(created_by AS string)                       AS created_by
    , CAST(last_modified_by AS string)                 AS last_modified_by
    , CAST(version AS bigint)                          AS version
    , CAST(deleted AS int)                             AS deleted
    , CAST(forwarded_to_inspection AS int)             AS forwarded_to_inspection
    , CAST(forwarded_at AS timestamp)                  AS forwarded_at
    , CAST(forwarded_by AS string)                     AS forwarded_by
    , CAST(violator_signed_file_url AS string)         AS violator_signed_file_url
    , CAST(violator_confirmed_receipt_at AS timestamp) AS violator_confirmed_receipt_at
    , CAST(violator_confirmed_by AS string)            AS violator_confirmed_by
    , CAST(recorder_unit_id AS string)                 AS recorder_unit_id
    , CAST(signature_type AS string)                   AS signature_type
    , CAST(first_signed_by AS string)                  AS first_signed_by
    , CAST(first_signed_at AS timestamp)               AS first_signed_at
    , CAST(signed_document_url AS string)              AS signed_document_url
    , CAST(receipt_status AS string)                   AS receipt_status
    , CAST(viewed_at AS timestamp)                     AS viewed_at
    , CAST(downloaded_at AS timestamp)                 AS downloaded_at
    , CAST(uploaded_signed_at AS timestamp)            AS uploaded_signed_at
    , CAST(assigned_signer_name AS string)             AS assigned_signer_name
    , CAST(assigned_signer_id AS string)               AS assigned_signer_id
    , CAST(assigned_leader_signer_id AS string)        AS assigned_leader_signer_id
    , CAST(assigned_leader_signer_name AS string)      AS assigned_leader_signer_name
    , CAST(created_by_ban_role AS string)              AS created_by_ban_role
    , CAST(signing_flow AS string)                     AS signing_flow
    , CAST(email_sent_at AS timestamp)                 AS email_sent_at
    , CAST(sms_sent_at AS timestamp)                   AS sms_sent_at
    , CAST(no_longer_violation AS int)                 AS no_longer_violation
    , CAST(no_longer_violation_note AS string)         AS no_longer_violation_note
    , CAST(no_longer_violation_at AS timestamp)        AS no_longer_violation_at
    , CAST(no_longer_violation_by AS string)           AS no_longer_violation_by
    , CAST(violation_time_from AS date)                AS violation_time_from
    , CAST(violation_time_to AS date)                  AS violation_time_to
FROM {{ source('source_thanhtra', 'raw_violation_record') }}