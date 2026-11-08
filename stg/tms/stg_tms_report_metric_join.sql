/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_metric_join
* Program name: Staging TMS.REPORT_METRIC_JOIN
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(template_id AS string)       AS template_id
    , CAST(metric_a_id AS string)       AS metric_a_id
    , CAST(metric_b_id AS string)       AS metric_b_id
    , CAST(join_attribute_id AS string) AS join_attribute_id
    , CAST(join_type AS string)         AS join_type
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_tms', 'raw_report_metric_join') }}