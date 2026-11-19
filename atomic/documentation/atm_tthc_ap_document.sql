/*
*--------------------------------------------------------------------*
* Program code: atm_tthc_ap_document
* Program name: Atomic TTHC Administrative Procedure Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT *
    FROM {{ ref('ods_tthc_ap_document') }}
)

SELECT
    {{ generate_surrogate_key_bigint('TTHC_AP_DOCUMENT', 'src.AP_DOCUMENT_ID') }}                       AS ap_document_id
    , CAST(src.AP_DOCUMENT_ID                                              AS STRING)                    AS ap_document_code
    , CAST('TTHC_AP_DOCUMENT'                                              AS STRING)                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('TTHC_AP_DOCUMENT_APPLICANT', 'src.AP_DOCUMENT_APPLICANT_ID') }}  AS ap_document_applicant_id
    , CAST(src.AP_DOCUMENT_APPLICANT_ID                                    AS STRING)                    AS ap_document_applicant_code
    , CAST(src.DOCUMENT_TITLE                                              AS STRING)                    AS document_title
    , CAST(src.SECURITIES_CODE                                             AS STRING)                    AS securities_code
    , CAST(src.PROCESSING_STATUS_CODE                                      AS STRING)                    AS processing_status_code
    , CAST(src.PROCESSING_AUTHORITY_CODE                                   AS STRING)                    AS processing_authority_code
    , CAST(src.DOCUMENT_TYPE_CODE                                          AS STRING)                    AS document_tp_code
    , CAST(src.DOMAIN_CODE                                                 AS STRING)                    AS domain_code
    , CAST(src.PRIORITY_LEVEL_CODE                                         AS STRING)                    AS priority_level_code
    , CAST(src.RECEPTION_CHANNEL_CODE                                      AS STRING)                    AS reception_channel_code
    , CAST(src.RETURN_METHOD_CODE                                          AS INT)                       AS return_method_code
    , CAST(src.PROCESSING_OFFICER_CODE                                     AS STRING)                    AS processing_officer_code
    , CAST(src.SUBMISSION_TIMESTAMP                                        AS TIMESTAMP)                 AS submission_tms
    , CAST(src.RECEPTION_TIMESTAMP                                         AS TIMESTAMP)                 AS reception_tms
    , CAST(src.PROCESSING_DEADLINE_TIMESTAMP                               AS TIMESTAMP)                 AS processing_deadline_tms
    , CAST(src.RESULT_RETURN_TIMESTAMP                                     AS TIMESTAMP)                 AS result_return_tms
    , CAST(src.FEE_PAID_INDICATOR                                          AS STRING)                    AS fee_paid_ind
    , CAST(src.FEE_AMOUNT                                                  AS DECIMAL(23, 2))            AS fee_amt
    , CAST(src.DOC_COMPONENT                                               AS STRING)                    AS doc_component
    , CAST(src.EFORM_DATA                                                  AS STRING)                    AS eform_data
FROM src
