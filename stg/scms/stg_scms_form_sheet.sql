/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_sheet
* Program name: Staging SCMS.FORM_SHEET
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(form_report_id AS bigint)      AS form_report_id
    , CAST(sheet_code AS string)          AS sheet_code
    , CAST(sheet_name AS string)          AS sheet_name
    , CAST(main_title AS string)          AS main_title
    , CAST(sub_title AS string)           AS sub_title
    , CAST(cover_page AS int)             AS cover_page
    , CAST(paper_size AS string)          AS paper_size
    , CAST(paper_orientation AS string)   AS paper_orientation
    , CAST(sort_order AS int)             AS sort_order
    , CAST(note AS string)                AS note
    , CAST(signatory AS string)           AS signatory
    , CAST(report_style AS string)        AS report_style
    , CAST(active AS int)                 AS active
    , CAST(record_status AS int)          AS record_status
    , CAST(created_by AS bigint)          AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(sub_title_position AS string)  AS sub_title_position
    , CAST(sub_title_enabled AS string)   AS sub_title_enabled
    , CAST(form_sheet_id AS bigint)       AS form_sheet_id
    , CAST(legacy_sheet_code AS string)   AS legacy_sheet_code
    , CAST(company_info AS string)        AS company_info
    , CAST(national_heading AS string)    AS national_heading
    , CAST(rptdetailid AS string)         AS rptdetailid
    , CAST(sync_column_code AS string)    AS sync_column_code
    , CAST(record_type AS int)            AS record_type
    , CAST(columnorder AS string)         AS columnorder
    , CAST(start_row AS int)              AS start_row
    , CAST(stt_column_code AS string)     AS stt_column_code
FROM {{ source('source_scms', 'raw_form_sheet') }}