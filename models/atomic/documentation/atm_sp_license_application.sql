/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_application
* Program name: Atomic Securities Practitioner License Application
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH appl_all AS (
    SELECT
        application_code
        , application_type
        , status_id
        , registration_type
        , certificate_id
        , title
        , submission_date
        , supplement_date
        , supplement_letter_date
        , certificate_number
        , issue_date
        , previous_certificate_number
        , previous_issue_date
        , previous_certificate_id
        , reissue_reason
        , rejection_reason
        , certificate_receipt_method
        , certificate_receipt_address
        , certificate_receipt_phone
        , receipt_status
        , is_violated
        , is_data_exploitable
        , reissue_hsm
        , note
        , professional_id
        , certificate_record_id
        , previous_certificate_record_id
        , exam_session_id
        , assignee_id
        , info_verify_id
        , mcdt_content_item_id
        , id
        , row_number() over (partition by application_code, status_id order by id desc) as rn
    FROM {{ ref('ods_nhnck_applications') }}
),

appl AS (
    SELECT
        application_code
        , application_type
        , status_id
        , registration_type
        , certificate_id
        , title
        , submission_date
        , supplement_date
        , supplement_letter_date
        , certificate_number
        , issue_date
        , previous_certificate_number
        , previous_issue_date
        , previous_certificate_id
        , reissue_reason
        , rejection_reason
        , certificate_receipt_method
        , certificate_receipt_address
        , certificate_receipt_phone
        , receipt_status
        , is_violated
        , is_data_exploitable
        , reissue_hsm
        , note
        , professional_id
        , certificate_record_id
        , previous_certificate_record_id
        , exam_session_id
        , assignee_id
        , info_verify_id
        , mcdt_content_item_id
    FROM appl_all
    where rn = 1
),

ap_st AS (
    SELECT
        id
        , status_code
    FROM {{ ref('ods_nhnck_application_statuses') }}
),

cert AS (
    SELECT
        id
        , certificate_code
    FROM {{ ref('ods_nhnck_certificates') }}
),

cert_prev AS (
    SELECT
        id
        , certificate_code
    FROM {{ ref('ods_nhnck_certificates') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.application_code") }}                        AS sp_license_application_id
    , CAST(appl.application_code AS string)                                                                   AS sp_license_application_code
    , CAST('NHNCK_APPLICATIONS' AS string)                                                                    AS src_stm_code
    , CAST(appl.application_type AS string)                                                                   AS application_tp_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATION_STATUSES', "ap_st.status_code") }}                  AS cl_application_status_id
    , CAST(appl.status_id AS string)                                                                          AS cl_application_status_code
    , CAST(appl.registration_type AS string)                                                                  AS registration_tp_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert.certificate_code") }}                      AS sp_license_certificate_tp_id
    , CAST(appl.certificate_id AS string)                                                                     AS sp_license_certificate_tp_code
    , CAST(appl.title AS string)                                                                              AS title
    , CAST(appl.submission_date AS date)                                                                      AS submission_dt
    , CAST(appl.supplement_date AS date)                                                                      AS supplement_dt
    , CAST(appl.supplement_letter_date AS date)                                                               AS supplement_letter_dt
    , CAST(appl.certificate_number AS string)                                                                 AS certificate_nbr
    , CAST(appl.issue_date AS date)                                                                           AS issue_dt
    , CAST(appl.previous_certificate_number AS string)                                                        AS previous_certificate_nbr
    , CAST(appl.previous_issue_date AS date)                                                                  AS previous_issue_dt
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert_prev.certificate_code") }}                 AS previous_sp_license_certificate_tp_id
    , CAST(appl.previous_certificate_id AS string)                                                            AS previous_sp_license_certificate_tp_code
    , CAST(appl.reissue_reason AS string)                                                                     AS reissue_reason
    , CAST(appl.rejection_reason AS string)                                                                   AS rejection_reason
    , CAST(appl.certificate_receipt_method AS string)                                                         AS certificate_receipt_method_code
    , CAST(appl.certificate_receipt_address AS string)                                                        AS certificate_receipt_adr
    , CAST(appl.certificate_receipt_phone AS string)                                                          AS certificate_receipt_phone
    , CAST(appl.receipt_status AS string)                                                                     AS receipt_status_code
    , CAST(appl.is_violated AS int)                                                                           AS violated_indicator
    , CAST(appl.is_data_exploitable AS int)                                                                   AS data_exploitable_indicator
    , CAST(appl.reissue_hsm AS string)                                                                        AS reissue_hsm
    , CAST(appl.note AS string)                                                                               AS note
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "appl.professional_id") }}                      AS sp_id
    , CAST(appl.professional_id AS string)                                                                    AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORDS', "appl.certificate_record_id") }}          AS sp_license_certificate_document_id
    , CAST(appl.certificate_record_id AS string)                                                              AS sp_license_certificate_document_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORDS', "appl.previous_certificate_record_id") }} AS previous_sp_license_certificate_document_id
    , CAST(appl.previous_certificate_record_id AS string)                                                     AS previous_sp_license_certificate_document_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.exam_session_id") }}                       AS sp_qualification_examination_assessment_id
    , CAST(appl.exam_session_id AS string)                                                                    AS sp_qualification_examination_assessment_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "appl.assignee_id") }}                                    AS assignee_officer_id
    , CAST(appl.assignee_id AS string)                                                                        AS assignee_officer_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "appl.info_verify_id") }}                                 AS info_verify_officer_id
    , CAST(appl.info_verify_id AS string)                                                                     AS info_verify_officer_code
    , CAST(appl.mcdt_content_item_id AS string)                                                               AS public_service_portal_content_item_code
FROM appl
    LEFT JOIN ap_st ON appl.STATUS_ID = ap_st.ID
    LEFT JOIN cert ON appl.CERTIFICATE_ID = cert.ID
    LEFT JOIN cert_prev ON appl.PREVIOUS_CERTIFICATE_ID = cert_prev.ID