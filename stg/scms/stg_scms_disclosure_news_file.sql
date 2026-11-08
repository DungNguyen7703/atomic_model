/*
*--------------------------------------------------------------------*
* Program code: stg_scms_disclosure_news_file
* Program name: Staging SCMS.DISCLOSURE_NEWS_FILE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu string sang binary (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(legacy_news_id AS decimal(20,0)) AS legacy_news_id
    , CAST(legacy_filename AS string)       AS legacy_filename
    , CAST(legacy_filedata AS binary)       AS legacy_filedata
FROM {{ source('source_scms', 'raw_disclosure_news_file') }}