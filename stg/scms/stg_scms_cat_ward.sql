/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_ward
* Program name: Staging SCMS.CAT_WARD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)            AS id
    , CAST(province_id AS bigint)   AS province_id
    , CAST(district_id AS bigint)   AS district_id
    , CAST(ward_code AS string)     AS ward_code
    , CAST(ward_name AS string)     AS ward_name
    , CAST(note AS string)          AS note
    , CAST(created_by AS bigint)    AS created_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(record_status AS int)    AS record_status
    , CAST(ecatalog_id AS string)   AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_ward') }}
