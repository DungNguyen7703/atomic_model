/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_chart_config
* Program name: Staging SCMS.OUTPUT_REPORT_CHART_CONFIG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))             AS id
    , CAST(form_report_id AS decimal(19,0)) AS form_report_id
    , CAST(line_marker_type AS string)      AS line_marker_type
    , CAST(round_point_type AS string)      AS round_point_type
    , CAST(round_marker_type AS string)     AS round_marker_type
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by AS decimal(19,0))     AS created_by
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(updated_by AS decimal(19,0))     AS updated_by
FROM {{ source('source_scms', 'raw_output_report_chart_config') }}