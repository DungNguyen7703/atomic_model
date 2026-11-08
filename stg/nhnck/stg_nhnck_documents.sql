/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_documents
* Program name: Staging NHNCK.DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(document_code AS string) AS document_code
    , CAST(document_name AS string) AS document_name
    , CAST(reference AS string)     AS reference
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(is_active AS int)        AS is_active
    , CAST(is_original_data AS int) AS is_original_data
    , CAST(sort_order AS bigint)    AS sort_order
    , CAST(status AS bigint)        AS status
    , CAST(mcdt_code AS string)     AS mcdt_code
    , CAST(updated_by AS bigint)    AS updated_by
FROM {{ source('source_nhnck', 'raw_documents') }}