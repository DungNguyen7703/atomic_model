/*
*--------------------------------------------------------------------*
* Program code: stg_tms_dashboard_user_config_item
* Program name: Staging TMS.DASHBOARD_USER_CONFIG_ITEM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(user_config_id AS string)  AS user_config_id
    , CAST(config_row_id AS string)   AS config_row_id
    , CAST(widget_id AS string)       AS widget_id
    , CAST(column_no AS int)          AS column_no
    , CAST(column_span AS int)        AS column_span
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_dashboard_user_config_item') }}