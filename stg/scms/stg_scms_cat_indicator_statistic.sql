/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_indicator_statistic
* Program name: Staging SCMS.CAT_INDICATOR_STATISTIC
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(indicator_id AS bigint)             AS indicator_id
    , CAST(statistic_catalog_id AS bigint)     AS statistic_catalog_id
    , CAST(catalog_id AS bigint)               AS catalog_id
    , CAST(statistic_indicator_code AS string) AS statistic_indicator_code
    , CAST(statistic_indicator_name AS string) AS statistic_indicator_name
    , CAST(last_modified_at AS timestamp)      AS last_modified_at
FROM {{ source('source_scms', 'raw_cat_indicator_statistic') }}