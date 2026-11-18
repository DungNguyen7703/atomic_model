/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_row_header
* Program name: Staging SCMS.FORM_ROW_HEADER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (8 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(form_sheet_id AS bigint)       AS form_sheet_id
    , CAST(sort_order AS int)             AS sort_order
    , CAST(version AS int)                AS version
    , CAST(alignment AS string)           AS alignment
    , CAST(hierarchy_level AS bigint)     AS hierarchy_level
    , CAST(start_column AS bigint)        AS start_column
    , CAST(end_column AS bigint)          AS end_column
    , CAST(bold AS int)                   AS bold
    , CAST(background_color AS string)    AS background_color
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS bigint)    AS last_modified_by
    , CAST(created_by AS bigint)          AS created_by
    , CAST(header_title AS string)        AS header_title
    , CAST(parent_header_id AS bigint)    AS parent_header_id
    , CAST(record_status AS int)          AS record_status
FROM {{ source('source_scms', 'raw_form_row_header') }}