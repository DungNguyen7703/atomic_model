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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (2 cot); them cot data_dt; yml snapshot/ds_snpst_dt -> append/data_dt theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(invoice_template_symbol AS string) AS invoice_template_symbol
    , CAST(invoice_symbol AS string)          AS invoice_symbol
    , CAST(invoice_number AS string)          AS invoice_number
    , CAST(tax_enforcement_invoice_id AS bigint) AS tax_enforcement_invoice_id
    , CAST(invoice_type AS string)            AS invoice_type
    , CAST(obj_id AS string)                  AS obj_id
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AS data_dt
FROM {{ source('source_knt', 'raw_invoice_detail') }}