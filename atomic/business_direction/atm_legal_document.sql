/*
*--------------------------------------------------------------------*
* Program code: atm_legal_document
* Program name: Atomic Legal Document
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD THANHTRA_LEGAL_DOCUMENT.
*--------------------------------------------------------------------*
*/

WITH le_do AS (
    SELECT
        code
        , name
        , issued_date
        , note
        , ecatalog_id
    FROM {{ ref('ods_thanhtra_legal_document') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_LEGAL_DOCUMENT', "le_do.code") }} AS legal_document_id
    , CAST(le_do.code AS string)                                                   AS legal_document_code
    , CAST('THANHTRA_LEGAL_DOCUMENT' AS string)                                    AS src_stm_code
    , CAST(le_do.name AS string)                                                   AS legal_document_nm
    , CAST(le_do.issued_date AS date)                                              AS issued_dt
    , CAST(le_do.note AS string)                                                   AS note
    , CAST(le_do.ecatalog_id AS string)                                            AS ecatalog_id
FROM le_do