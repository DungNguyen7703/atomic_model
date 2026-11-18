/*
*--------------------------------------------------------------------*
* Program code: atm_cl_document
* Program name: Atomic Classification Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH docu AS (
    SELECT
        id
        , document_code
        , document_name
        , reference
        , sort_order
        , is_active
        , is_original_data
        , mcdt_code
    FROM {{ ref('ods_nhnck_documents') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_DOCUMENTS', "docu.document_code") }} AS cl_document_id
    , CAST(docu.document_code AS string)                                         AS cl_document_code
    , CAST('NHNCK_DOCUMENTS' AS string)                                          AS src_stm_code
    , CAST(docu.document_name AS string)                                         AS cl_document_nm
    , CAST(docu.reference AS string)                                             AS legal_reference
    , CAST(docu.sort_order AS int)                                               AS sort_order
    , CAST(docu.is_active AS string)                                             AS active_ind
    , CAST(docu.is_original_data AS string)                                      AS original_data_ind
    , CAST(docu.mcdt_code AS string)                                             AS public_service_portal_code
FROM docu