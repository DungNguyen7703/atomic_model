/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_form
* Program name: Staging KNT.REPORT_FORM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)           AS id
    , CAST(form_code AS string) AS form_code
    , CAST(form_name AS string) AS form_name
    , CAST(system_code AS int)  AS system_code
FROM {{ source('source_knt', 'raw_report_form') }}