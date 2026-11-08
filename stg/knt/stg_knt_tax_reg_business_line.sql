/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_reg_business_line
* Program name: Staging KNT.TAX_REG_BUSINESS_LINE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(tax_code AS string)                AS tax_code
    , CAST(business_line_code AS string)      AS business_line_code
    , CAST(business_line_name AS string)      AS business_line_name
    , CAST(packet_code AS string)             AS packet_code
    , CAST(main_business_line_flag AS string) AS main_business_line_flag
FROM {{ source('source_knt', 'raw_tax_reg_business_line') }}