/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_registration_list
* Program name: Staging KNT.TAX_REGISTRATION_LIST
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)            AS id
    , CAST(tax_code AS string)      AS tax_code
    , CAST(change_date AS date)     AS change_date
    , CAST(year AS int)             AS year
    , CAST(detail_sync_flag AS int) AS detail_sync_flag
FROM {{ source('source_knt', 'raw_tax_registration_list') }}