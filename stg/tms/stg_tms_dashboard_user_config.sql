/*
*--------------------------------------------------------------------*
* Program code: stg_tms_dashboard_user_config
* Program name: Staging TMS.DASHBOARD_USER_CONFIG
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
    , CAST(dashboard_id AS string)      AS dashboard_id
    , CAST(user_id AS string)           AS user_id
    , CAST(source_version_id AS string) AS source_version_id
    , CAST(status AS int)               AS status
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
    , CAST(is_customized AS int)        AS is_customized
FROM {{ source('source_tms', 'raw_dashboard_user_config') }}