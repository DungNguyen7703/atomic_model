/*
*--------------------------------------------------------------------*
* Program code: stg_tms_dashboard_admin_config_version
* Program name: Staging TMS.DASHBOARD_ADMIN_CONFIG_VERSION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(user_config_id AS string)           AS user_config_id
    , CAST(version AS int)                     AS version
    , CAST(change_summary AS string)           AS change_summary
    , CAST(changed_by_id AS string)            AS changed_by_id
    , CAST(changed_by_name AS string)          AS changed_by_name
    , CAST(changed_at AS timestamp)            AS changed_at
    , CAST(rollback_from_version_id AS string) AS rollback_from_version_id
    , CAST(is_current AS int)                  AS is_current
    , CAST(status AS int)                      AS status
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(deleted AS int)                     AS deleted
FROM {{ source('source_tms', 'raw_dashboard_admin_config_version') }}