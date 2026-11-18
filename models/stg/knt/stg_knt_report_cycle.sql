/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_cycle
* Program name: Staging KNT.REPORT_CYCLE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(cycle_code AS string) AS cycle_code
    , CAST(value AS string)      AS value
    , CAST(month_num AS int)     AS month_num
    , CAST(year_num AS int)      AS year_num
FROM {{ source('source_knt', 'raw_report_cycle') }}