/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_applications
* Program name: Staging NHNCK.APPLICATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (16 cot); kieu date sang timestamp (2 cot); them cot mcdt_personal_snapshot, re_exam_subject, receive_channel, receive_channel_code.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                               AS id
    , CAST(professional_id AS bigint)                AS professional_id
    , CAST(status_id AS bigint)                      AS status_id
    , CAST(certificate_id AS bigint)                 AS certificate_id
    , CAST(certificate_record_id AS bigint)          AS certificate_record_id
    , CAST(previous_certificate_id AS bigint)        AS previous_certificate_id
    , CAST(previous_certificate_record_id AS bigint) AS previous_certificate_record_id
    , CAST(exam_session_id AS bigint)                AS exam_session_id
    , CAST(registration_type AS bigint)              AS registration_type
    , CAST(application_type AS bigint)               AS application_type
    , CAST(application_code AS string)               AS application_code
    , CAST(title AS string)                          AS title
    , CAST(submission_date AS date)                  AS submission_date
    , CAST(supplement_date AS date)                  AS supplement_date
    , CAST(reissue_reason AS string)                 AS reissue_reason
    , CAST(rejection_reason AS string)               AS rejection_reason
    , CAST(certificate_number AS string)             AS certificate_number
    , CAST(issue_date AS date)                       AS issue_date
    , CAST(previous_certificate_number AS string)    AS previous_certificate_number
    , CAST(previous_issue_date AS date)              AS previous_issue_date
    , CAST(note AS string)                           AS note
    , CAST(is_violated AS int)                       AS is_violated
    , CAST(is_data_exploitable AS int)               AS is_data_exploitable
    , CAST(assignee_id AS bigint)                    AS assignee_id
    , CAST(info_verify_id AS bigint)                 AS info_verify_id
    , CAST(certificate_receipt_method AS bigint)     AS certificate_receipt_method
    , CAST(certificate_receipt_address AS string)    AS certificate_receipt_address
    , CAST(receipt_status AS bigint)                 AS receipt_status
    , CAST(supplement_letter_date AS date)           AS supplement_letter_date
    , CAST(certificate_receipt_phone AS string)      AS certificate_receipt_phone
    , CAST(reissue_hsm AS string)                    AS reissue_hsm
    , CAST(created_at AS timestamp)                  AS created_at
    , CAST(updated_at AS timestamp)                  AS updated_at
    , CAST(updated_by AS bigint)                     AS updated_by
    , CAST(created_by AS bigint)                     AS created_by
    , CAST(mcdt_content_item_id AS string)           AS mcdt_content_item_id
    , CAST(mcdt_personal_snapshot AS string)         AS mcdt_personal_snapshot
    , CAST(re_exam_subject AS string)                AS re_exam_subject
    , CAST(receive_channel AS string)                AS receive_channel
    , CAST(receive_channel_code AS string)           AS receive_channel_code
FROM {{ source('source_nhnck', 'raw_applications') }}