/*
*--------------------------------------------------------------------*
* Program code: stg_tms_dashboard_admin_config_region
* Program name: Staging TMS.DASHBOARD_ADMIN_CONFIG_REGION
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
    , CAST(config_version_id AS string) AS config_version_id
    , CAST(region_name AS string)       AS region_name
    , CAST(display_order AS int)        AS display_order
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_tms', 'raw_dashboard_admin_config_region') }}