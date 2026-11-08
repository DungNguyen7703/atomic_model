/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_enforcement_list
* Program name: Staging KNT.TAX_ENFORCEMENT_LIST
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(taxpayer_tax_code AS string)  AS taxpayer_tax_code
    , CAST(decision_number AS string)    AS decision_number
    , CAST(decision_date AS date)        AS decision_date
    , CAST(year AS int)                  AS year
    , CAST(tax_authority_code AS string) AS tax_authority_code
    , CAST(detail_sync_flag AS int)      AS detail_sync_flag
FROM {{ source('source_knt', 'raw_tax_enforcement_list') }}