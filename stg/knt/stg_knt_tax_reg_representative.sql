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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(representative_name AS string)   AS representative_name
    , CAST(position AS string)              AS position
    , CAST(id_document_type AS string)      AS id_document_type
    , CAST(id_document_number AS string)    AS id_document_number
    , CAST(issue_date AS date)              AS issue_date
    , CAST(phone AS string)                 AS phone
    , CAST(fax AS string)                   AS fax
    , CAST(email AS string)                 AS email
    , CAST(tax_registration_id AS int)      AS tax_registration_id
    , CAST(id_document_type_desc AS string) AS id_document_type_desc
FROM {{ source('source_knt', 'raw_tax_reg_representative') }}