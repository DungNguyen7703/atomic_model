/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_template_config
* Program name: Staging TMS.REPORT_TEMPLATE_CONFIG
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
    , CAST(code AS string)            AS code
    , CAST(name AS string)            AS name
    , CAST(description AS string)     AS description
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
    , CAST(critical AS int)           AS critical
    , CAST(template_role AS int)      AS template_role
    , CAST(template_type AS int)      AS template_type
    , CAST(file_path AS string)       AS file_path
    , CAST(file_name AS string)       AS file_name
    , CAST(data_source AS int)        AS data_source
    , CAST(layout_type AS int)        AS layout_type
FROM {{ source('source_tms', 'raw_report_template_config') }}