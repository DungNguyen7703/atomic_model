/*
*--------------------------------------------------------------------*
* Program code: stg_tms_dashboard_widget
* Program name: Staging TMS.DASHBOARD_WIDGET
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(dashboard_widget_group_id AS string) AS dashboard_widget_group_id
    , CAST(widget_code AS string)               AS widget_code
    , CAST(widget_name AS string)               AS widget_name
    , CAST(widget_type AS int)                  AS widget_type
    , CAST(api_code AS string)                  AS api_code
    , CAST(display_order AS int)                AS display_order
    , CAST(description AS string)               AS description
    , CAST(status AS int)                       AS status
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(updated_at AS timestamp)             AS updated_at
    , CAST(created_by_id AS string)             AS created_by_id
    , CAST(updated_by_id AS string)             AS updated_by_id
    , CAST(created_by_name AS string)           AS created_by_name
    , CAST(updated_by_name AS string)           AS updated_by_name
    , CAST(deleted AS int)                      AS deleted
    , CAST(data_type AS string)                 AS data_type
    , CAST(default_value AS string)             AS default_value
    , CAST(filter_code AS string)               AS filter_code
    , CAST(filter_name AS string)               AS filter_name
FROM {{ source('source_tms', 'raw_dashboard_widget') }}