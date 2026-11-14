/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_document_attachment_content
* Program name: Staging THANHTRA.DOCUMENT_ATTACHMENT_CONTENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu file_content string sang binary.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(attachment_id AS string)  AS attachment_id
    , CAST(file_content AS binary)  AS file_content
FROM {{ source('source_thanhtra', 'raw_document_attachment_content') }}