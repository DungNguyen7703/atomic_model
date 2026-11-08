/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_document_attachment_content
* Program name: Staging THANHTRA.DOCUMENT_ATTACHMENT_CONTENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(attachment_id AS string)  AS attachment_id
    , CAST(file_content AS string) AS file_content
FROM {{ source('source_thanhtra', 'raw_document_attachment_content') }}