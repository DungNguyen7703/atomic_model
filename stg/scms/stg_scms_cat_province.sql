/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_province
* Program name: Staging SCMS.CAT_PROVINCE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)            AS id
    , CAST(province_code AS string) AS province_code
    , CAST(province_name AS string) AS province_name
    , CAST(note AS string)          AS note
    , CAST(created_by AS bigint)    AS created_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(record_status AS int)    AS record_status
    , CAST(ecatalog_id AS string)   AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_province') }}
