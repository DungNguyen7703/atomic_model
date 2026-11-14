/*
*--------------------------------------------------------------------*
* Program code: stg_knt_indicator_mapping
* Program name: Staging KNT.INDICATOR_MAPPING
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
    CAST(id AS bigint)                 AS id
    , CAST(declaration_code AS string)   AS declaration_code
    , CAST(sheet_name AS string)         AS sheet_name
    , CAST(ssc_indicator_code AS string) AS ssc_indicator_code
    , CAST(tax_indicator_code AS string) AS tax_indicator_code
    , CAST(indicator_name AS string)     AS indicator_name
    , CAST(description AS string)        AS description
FROM {{ source('source_knt', 'raw_indicator_mapping') }}