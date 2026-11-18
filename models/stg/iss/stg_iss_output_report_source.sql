/*
*--------------------------------------------------------------------*
* Program code: stg_iss_output_report_source
* Program name: Staging ISS.OUTPUT_REPORT_SOURCE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(input_report_template_id AS string)  AS input_report_template_id
    , CAST(output_report_template_id AS string) AS output_report_template_id
FROM {{ source('source_iss', 'raw_output_report_source') }}