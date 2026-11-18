/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_district
* Program name: Staging SCMS.CAT_DISTRICT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql: yml chuyen append/created_at sang snapshot/ds_snpst_dt.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)            AS id
    , CAST(province_id AS bigint)   AS province_id
    , CAST(district_code AS string) AS district_code
    , CAST(district_name AS string) AS district_name
    , CAST(note AS string)          AS note
    , CAST(created_by AS bigint)    AS created_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(record_status AS int)    AS record_status
FROM {{ source('source_scms', 'raw_cat_district') }}
