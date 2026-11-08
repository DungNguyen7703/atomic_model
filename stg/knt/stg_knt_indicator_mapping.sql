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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(declaration_code AS string)   AS declaration_code
    , CAST(sheet_name AS string)         AS sheet_name
    , CAST(ssc_indicator_code AS string) AS ssc_indicator_code
    , CAST(tax_indicator_code AS string) AS tax_indicator_code
    , CAST(indicator_name AS string)     AS indicator_name
    , CAST(description AS string)        AS description
FROM {{ source('source_knt', 'raw_indicator_mapping') }}