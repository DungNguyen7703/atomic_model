/*
*--------------------------------------------------------------------*
* Program code: atm_anti_corruption_document
* Program name: Atomic Anti Corruption Document
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_THANHTRA_ANTI_CORRUPTION_DOCUMENT.yaml (Relative -> scd2). BK = ID nguon (PK UUID); ODS da loc deleted = 0.
*--------------------------------------------------------------------*
*/

WITH doc AS (
    SELECT
        id
        , document_type
        , document_number
        , issued_date
        , document_year
        , quarter
        , receiving_unit
    FROM {{ ref('ods_thanhtra_anti_corruption_document') }}
    WHERE id IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_ANTI_CORRUPTION_DOCUMENT', "doc.id") }} AS anti_corruption_document_id
    , CAST(doc.id AS string)                                          AS anti_corruption_document_code
    , CAST('THANHTRA_ANTI_CORRUPTION_DOCUMENT' AS string)                                  AS src_stm_code
    , CAST(doc.document_type AS string)                               AS document_tp_code
    , CAST(doc.document_number AS string)                             AS document_nbr
    , CAST(doc.issued_date AS date)                                   AS issued_dt
    , CAST(doc.document_year AS int)                                  AS document_year
    , CAST(doc.quarter AS string)                                     AS document_quarter
    , CAST(doc.receiving_unit AS string)                              AS receiving_unit
FROM doc
