/*
*--------------------------------------------------------------------*
* Program code: stg_scms_document_folder
* Program name: Staging SCMS.DOCUMENT_FOLDER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)          AS id
    , CAST(folder_name AS string) AS folder_name
    , CAST(description AS string) AS description
    , CAST(user_id AS bigint)     AS user_id
FROM {{ source('source_scms', 'raw_document_folder') }}