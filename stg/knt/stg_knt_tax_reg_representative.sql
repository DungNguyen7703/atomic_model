/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_reg_representative
* Program name: Staging KNT.TAX_REG_REPRESENTATIVE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang decimal(38,10) (2 cot); kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,10))                  AS id
    , CAST(representative_name AS string)   AS representative_name
    , CAST(position AS string)              AS position
    , CAST(id_document_type AS string)      AS id_document_type
    , CAST(id_document_number AS string)    AS id_document_number
    , CAST(issue_date AS timestamp)               AS issue_date
    , CAST(phone AS string)                 AS phone
    , CAST(fax AS string)                   AS fax
    , CAST(email AS string)                 AS email
    , CAST(tax_registration_id AS decimal(38,10)) AS tax_registration_id
    , CAST(id_document_type_desc AS string) AS id_document_type_desc
FROM {{ source('source_knt', 'raw_tax_reg_representative') }}