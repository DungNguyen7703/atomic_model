/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_indicator
* Program name: Staging KNT.REPORT_INDICATOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(indicator_code AS string) AS indicator_code
    , CAST(indicator_name AS string) AS indicator_name
FROM {{ source('source_knt', 'raw_report_indicator') }}