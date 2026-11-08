/*
*--------------------------------------------------------------------*
* Program code: stg_knt_ttcs_request_tax_code_cache
* Program name: Staging KNT.TTCS_REQUEST_TAX_CODE_CACHE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(system_code AS int)        AS system_code
    , CAST(tax_code AS string)        AS tax_code
    , CAST(name AS string)            AS name
    , CAST(source_id AS int)          AS source_id
    , CAST(refreshed_at AS timestamp) AS refreshed_at
FROM {{ source('source_knt', 'raw_ttcs_request_tax_code_cache') }}