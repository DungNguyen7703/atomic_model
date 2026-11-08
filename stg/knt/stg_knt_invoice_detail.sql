/*
*--------------------------------------------------------------------*
* Program code: stg_knt_invoice_detail
* Program name: Staging KNT.INVOICE_DETAIL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(invoice_template_symbol AS string) AS invoice_template_symbol
    , CAST(invoice_symbol AS string)          AS invoice_symbol
    , CAST(invoice_number AS string)          AS invoice_number
    , CAST(tax_enforcement_invoice_id AS int) AS tax_enforcement_invoice_id
    , CAST(invoice_type AS string)            AS invoice_type
    , CAST(obj_id AS string)                  AS obj_id
FROM {{ source('source_knt', 'raw_invoice_detail') }}