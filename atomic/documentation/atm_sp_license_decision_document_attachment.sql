/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_decision_document_attachment
* Program name: Atomic Securities Practitioner License Decision Document Attachment
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_DECISION_DOCUMENTS.
*--------------------------------------------------------------------*
*/

WITH de_do AS (
    SELECT
        id
        , decision_id
        , type
        , position
        , file_path
        , signed_by
        , signed_date
        , status
    FROM {{ ref('ods_nhnck_decision_documents') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_DECISION_DOCUMENTS', "de_do.id") }} AS sp_license_decision_document_attachment_id
    , CAST(de_do.id AS string)                                                    AS sp_license_decision_document_attachment_code
    , CAST('NHNCK_DECISION_DOCUMENTS' AS string)                                  AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "de_do.decision_id") }} AS sp_license_decision_document_id
    , CAST(de_do.decision_id AS string)                                           AS sp_license_decision_document_code
    , CAST(de_do.type AS string)                                                  AS attachment_tp_code
    , CAST(de_do.position AS string)                                              AS signatory_position
    , CAST(de_do.file_path AS string)                                             AS attachment_file_path
    , CAST(de_do.signed_by AS string)                                             AS signed_by_officer_nm
    , CAST(de_do.signed_date AS date)                                             AS signed_dt
    , CAST(de_do.status AS string)                                                AS status_code
FROM de_do