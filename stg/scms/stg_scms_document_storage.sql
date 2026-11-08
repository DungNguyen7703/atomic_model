/*
*--------------------------------------------------------------------*
* Program code: stg_scms_document_storage
* Program name: Staging SCMS.DOCUMENT_STORAGE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: entry_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(company_name AS string)    AS company_name
    , CAST(folder_id AS bigint)       AS folder_id
    , CAST(attachment_path AS string) AS attachment_path
    , CAST(note AS string)            AS note
    , CAST(entry_date AS date)   AS entry_date
FROM {{ source('source_scms', 'raw_document_storage') }}