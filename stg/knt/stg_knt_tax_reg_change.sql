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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)          AS id
    , CAST(tax_code AS string) AS tax_code
    , CAST(changed_at AS date) AS changed_at
FROM {{ source('source_knt', 'raw_tax_reg_change') }}