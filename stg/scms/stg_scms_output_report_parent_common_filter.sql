/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_parent_common_filter
* Program name: Staging SCMS.OUTPUT_REPORT_PARENT_COMMON_FILTER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                AS id
    , CAST(parent_report_id AS decimal(19,0))  AS parent_report_id
    , CAST(filter_catalog_id AS decimal(19,0)) AS filter_catalog_id
    , CAST(is_common AS int)                   AS is_common
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(created_by AS decimal(19,0))        AS created_by
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(updated_by AS decimal(19,0))        AS updated_by
    , CAST(allow_select AS int)                AS allow_select
FROM {{ source('source_scms', 'raw_output_report_parent_common_filter') }}