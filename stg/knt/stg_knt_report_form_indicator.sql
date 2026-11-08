/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_form_indicator
* Program name: Staging KNT.REPORT_FORM_INDICATOR
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
    , CAST(report_form_id AS int)    AS report_form_id
    , CAST(form_indicator_id AS int) AS form_indicator_id
    , CAST(sort_order AS int)        AS sort_order
    , CAST(sheet_name AS string)     AS sheet_name
FROM {{ source('source_knt', 'raw_report_form_indicator') }}