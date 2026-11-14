/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_document_template_version
* Program name: Staging THANHTRA.DOCUMENT_TEMPLATE_VERSION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (1 cot); kieu docx_content string sang binary.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(template_id AS string)         AS template_id
    , CAST(version_number AS bigint)      AS version_number
    , CAST(file_name AS string)           AS file_name
    , CAST(docx_content AS binary)        AS docx_content
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_thanhtra', 'raw_document_template_version') }}