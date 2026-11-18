/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_indicator_catalog
* Program name: Staging SCMS.CAT_INDICATOR_CATALOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)             AS id
    , CAST(catalog_name AS string)   AS catalog_name
    , CAST(table_name AS string)     AS table_name
    , CAST(field_name AS string)     AS field_name
    , CAST(sort_order AS int)        AS sort_order
    , CAST(active AS int)            AS active
    , CAST(display_type AS int)      AS display_type
    , CAST(sort_by AS string)        AS sort_by
    , CAST(hierarchy_level AS int)   AS hierarchy_level
    , CAST(last_modified_at AS timestamp) AS last_modified_at
FROM {{ source('source_scms', 'raw_cat_indicator_catalog') }}