/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_documents
* Program name: Staging NHNCK.CERTIFICATE_DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(certificate_id AS bigint)       AS certificate_id
    , CAST(document_id AS bigint)          AS document_id
    , CAST(is_required AS int)             AS is_required
    , CAST(sort_order AS bigint)           AS sort_order
    , CAST(format AS string)               AS format
    , CAST(is_attachment_displayed AS int) AS is_attachment_displayed
    , CAST(document_type AS bigint)        AS document_type
    , CAST(is_display AS int)              AS is_display
FROM {{ source('source_nhnck', 'raw_certificate_documents') }}