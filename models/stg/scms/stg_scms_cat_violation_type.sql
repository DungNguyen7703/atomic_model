/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_violation_type
* Program name: Staging SCMS.CAT_VIOLATION_TYPE
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
    CAST(id AS bigint)                  AS id
    , CAST(violation_type_code AS string) AS violation_type_code
    , CAST(violation_type_name AS string) AS violation_type_name
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(ecatalog_id AS string)         AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_violation_type') }}