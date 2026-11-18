/*
*--------------------------------------------------------------------*
* Program code: stg_tms_user_table_config
* Program name: Staging TMS.USER_TABLE_CONFIG
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
    , CAST(user_id AS string)         AS user_id
    , CAST(table_name AS string)      AS table_name
    , CAST(table_code AS string)      AS table_code
    , CAST(tab_name AS string)        AS tab_name
    , CAST(tab_code AS string)        AS tab_code
    , CAST(config_data AS string)     AS config_data
    , CAST(notes AS string)           AS notes
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_user_table_config') }}