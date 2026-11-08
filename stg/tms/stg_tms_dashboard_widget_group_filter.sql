/*
*--------------------------------------------------------------------*
* Program code: stg_tms_dashboard_widget_group_filter
* Program name: Staging TMS.DASHBOARD_WIDGET_GROUP_FILTER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(dashboard_widget_group_id AS string)  AS dashboard_widget_group_id
    , CAST(dashboard_widget_filter_id AS string) AS dashboard_widget_filter_id
    , CAST(display_order AS int)                 AS display_order
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(created_by_id AS string)              AS created_by_id
    , CAST(updated_by_id AS string)              AS updated_by_id
    , CAST(created_by_name AS string)            AS created_by_name
    , CAST(updated_by_name AS string)            AS updated_by_name
    , CAST(deleted AS int)                       AS deleted
FROM {{ source('source_tms', 'raw_dashboard_widget_group_filter') }}