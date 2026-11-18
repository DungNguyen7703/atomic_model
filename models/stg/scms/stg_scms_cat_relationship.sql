/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_relationship
* Program name: Staging SCMS.CAT_RELATIONSHIP
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
    CAST(id AS bigint)                AS id
    , CAST(relationship_code AS string) AS relationship_code
    , CAST(relationship_name AS string) AS relationship_name
    , CAST(note AS string)              AS note
    , CAST(created_by AS bigint)        AS created_by
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(record_status AS int)        AS record_status
    , CAST(ecatalog_id AS string)       AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_relationship') }}