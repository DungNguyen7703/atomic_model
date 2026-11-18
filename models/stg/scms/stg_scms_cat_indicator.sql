/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_indicator
* Program name: Staging SCMS.CAT_INDICATOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(indicator_catalog_id AS bigint)  AS indicator_catalog_id
    , CAST(indicator_code AS string)        AS indicator_code
    , CAST(indicator_name AS string)        AS indicator_name
    , CAST(parent_hierarchy_code AS string) AS parent_hierarchy_code
    , CAST(hierarchy_code AS string)        AS hierarchy_code
    , CAST(hierarchy_level AS int)          AS hierarchy_level
    , CAST(data_type AS int)                AS data_type
    , CAST(active AS int)                   AS active
    , CAST(catalog_level AS string)         AS catalog_level
    , CAST(calculation_method AS int)       AS calculation_method
    , CAST(description AS string)           AS description
    , CAST(created_by AS bigint)            AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS bigint)      AS last_modified_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
FROM {{ source('source_scms', 'raw_cat_indicator') }}