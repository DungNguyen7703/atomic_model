/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_form_template
* Program name: Staging KNT.REPORT_FORM_TEMPLATE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(report_type AS int)       AS report_type
    , CAST(report_name AS string)    AS report_name
    , CAST(report_code AS string)    AS report_code
    , CAST(system_code AS int)       AS system_code
    , CAST(sheet_index AS int)       AS sheet_index
    , CAST(indicator_code AS string) AS indicator_code
    , CAST(indicator_name AS string) AS indicator_name
    , CAST(status AS int)            AS status
    , CAST(report_period AS string)  AS report_period
FROM {{ source('source_knt', 'raw_report_form_template') }}