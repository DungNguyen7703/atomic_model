/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_reg_change
* Program name: Staging KNT.TAX_REG_CHANGE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang decimal(38,10) (1 cot); kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,10))    AS id
    , CAST(tax_code AS string) AS tax_code
    , CAST(changed_at AS timestamp) AS changed_at
FROM {{ source('source_knt', 'raw_tax_reg_change') }}