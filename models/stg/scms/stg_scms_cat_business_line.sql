/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_business_line
* Program name: Staging SCMS.CAT_BUSINESS_LINE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql: yml chuyen append/created_at sang snapshot/ds_snpst_dt.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(business_line_code AS string)   AS business_line_code
    , CAST(business_line_name AS string)   AS business_line_name
    , CAST(note AS string)                 AS note
    , CAST(created_by AS bigint)           AS created_by
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(record_status AS int)           AS record_status
    , CAST(legal_capital AS decimal(38,0)) AS legal_capital
FROM {{ source('source_scms', 'raw_cat_business_line') }}