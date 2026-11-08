/*
*--------------------------------------------------------------------*
* Program code: stg_scms_help_document
* Program name: Staging SCMS.HELP_DOCUMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(document_name AS string)       AS document_name
    , CAST(note AS string)                AS note
    , CAST(attachment_path AS string)     AS attachment_path
    , CAST(created_by AS bigint)          AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(record_status AS bigint)       AS record_status
FROM {{ source('source_scms', 'raw_help_document') }}