/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_certificate_document
* Program name: Atomic Securities Practitioner License Certificate Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ce_re AS (
    SELECT
        id
        , certificate_number
        , certificate_id
        , professional_id
        , issue_decision_id
        , revocation_decision_id
        , cancellation_decision_id
        , issue_date
        , revocation_date
        , revocation_reason
        , professional_full_name
        , allow_reissue
        , process_status
        , cer_path
        , conversion_status
        , description
        , status
    FROM {{ ref('ods_nhnck_certificate_records') }}
),

cert AS (
    SELECT
        id
        , certificate_code
    FROM {{ ref('ods_nhnck_certificates') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORDS', "ce_re.id") }}               AS sp_license_certificate_document_id
    , CAST(ce_re.id AS string)                                                                 AS sp_license_certificate_document_code
    , CAST('NHNCK_CERTIFICATE_RECORDS' AS string)                                              AS src_stm_code
    , CAST(ce_re.certificate_number AS string)                                                 AS certificate_nbr
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert.certificate_code") }}       AS sp_license_certificate_tp_id
    , CAST(cert.certificate_code AS string)                                                    AS sp_license_certificate_tp_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "ce_re.professional_id") }}      AS sp_id
    , CAST(ce_re.professional_id AS string)                                                    AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ce_re.issue_decision_id") }}        AS issue_sp_license_decision_document_id
    , CAST(ce_re.issue_decision_id AS string)                                                  AS issue_sp_license_decision_document_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ce_re.revocation_decision_id") }}   AS revocation_sp_license_decision_document_id
    , CAST(ce_re.revocation_decision_id AS string)                                             AS revocation_sp_license_decision_document_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ce_re.cancellation_decision_id") }} AS cancellation_sp_license_decision_document_id
    , CAST(ce_re.cancellation_decision_id AS string)                                           AS cancellation_sp_license_decision_document_code
    , CAST(ce_re.issue_date AS date)                                                           AS issue_dt
    , CAST(ce_re.revocation_date AS date)                                                      AS revocation_dt
    , CAST(ce_re.revocation_reason AS string)                                                  AS revocation_reason
    , CAST(ce_re.professional_full_name AS string)                                             AS practitioner_nm_at_issuance
    , CAST(ce_re.allow_reissue AS int)                                                         AS reissuance_allowed_count
    , CAST(ce_re.process_status AS string)                                                     AS process_status_code
    , CAST(ce_re.cer_path AS string)                                                           AS certificate_file_path
    , CAST(ce_re.conversion_status AS string)                                                  AS conversion_status_code
    , CAST(ce_re.description AS string)                                                        AS description
    , CAST(ce_re.status AS string)                                                             AS status_code
FROM ce_re
    LEFT JOIN cert ON ce_re.CERTIFICATE_ID = cert.ID