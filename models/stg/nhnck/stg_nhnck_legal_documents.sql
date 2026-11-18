/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_legal_documents
* Program name: Staging NHNCK.LEGAL_DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(document_number AS string) AS document_number
    , CAST(document_name AS string)   AS document_name
    , CAST(issuing_agency AS string)  AS issuing_agency
    , CAST(reference AS string)       AS reference
    , CAST(file_name AS string)       AS file_name
    , CAST(file_path AS string)       AS file_path
    , CAST(issue_date AS date)        AS issue_date
    , CAST(position AS string)        AS position
    , CAST(signatory AS string)       AS signatory
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(created_by AS bigint)      AS created_by
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(status AS bigint)          AS status
    , CAST(is_featured AS bigint)     AS is_featured
    , CAST(reason AS string)          AS reason
    , CAST(updated_by AS bigint)      AS updated_by
FROM {{ source('source_nhnck', 'raw_legal_documents') }}