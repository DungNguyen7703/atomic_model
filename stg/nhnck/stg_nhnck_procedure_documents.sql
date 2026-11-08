/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_procedure_documents
* Program name: Staging NHNCK.PROCEDURE_DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)             AS id
    , CAST(procedure_id AS bigint) AS procedure_id
    , CAST(document_id AS bigint)  AS document_id
FROM {{ source('source_nhnck', 'raw_procedure_documents') }}