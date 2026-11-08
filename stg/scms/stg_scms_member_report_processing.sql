/*
*--------------------------------------------------------------------*
* Program code: stg_scms_member_report_processing
* Program name: Staging SCMS.MEMBER_REPORT_PROCESSING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: processing_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(member_report_id AS bigint) AS member_report_id
    , CAST(processor_name AS string)  AS processor_name
    , CAST(processing_date AS date) AS processing_date
    , CAST(reason AS string)          AS reason
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(attachment_path AS string) AS attachment_path
    , CAST(record_status AS int)      AS record_status
    , CAST(version AS int)            AS version
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(processor_id AS bigint)    AS processor_id
    , CAST(content AS string)         AS content
    , CAST(status_after AS bigint)    AS status_after
    , CAST(status_before AS bigint)   AS status_before
FROM {{ source('source_scms', 'raw_member_report_processing') }}