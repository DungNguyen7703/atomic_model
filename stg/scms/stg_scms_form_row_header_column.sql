/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_row_header_column
* Program name: Staging SCMS.FORM_ROW_HEADER_COLUMN
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
    CAST(id AS bigint)              AS id
    , CAST(form_sheet_id AS bigint)   AS form_sheet_id
    , CAST(form_row_header_id AS bigint) AS form_row_header_id
    , CAST(column_name AS string)     AS column_name
    , CAST(column_name_en AS string)  AS column_name_en
    , CAST(sort_order AS int)         AS sort_order
    , CAST(first_row AS int)          AS first_row
    , CAST(last_row AS int)           AS last_row
    , CAST(first_column AS int)       AS first_column
    , CAST(last_column AS int)        AS last_column
    , CAST(row_span AS int)           AS row_span
    , CAST(col_span AS int)           AS col_span
    , CAST(hidden AS int)             AS hidden
    , CAST(version AS int)            AS version
FROM {{ source('source_scms', 'raw_form_row_header_column') }}