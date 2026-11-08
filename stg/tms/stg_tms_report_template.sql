/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_template
* Program name: Staging TMS.REPORT_TEMPLATE
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
    , CAST(template_code AS string)   AS template_code
    , CAST(template_name AS string)   AS template_name
    , CAST(template_type AS int)      AS template_type
    , CAST(template_config AS string) AS template_config
    , CAST(data_source AS string)     AS data_source
    , CAST(parameters AS string)      AS parameters
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(version AS int)            AS version
    , CAST(deleted AS int)            AS deleted
    , CAST(file_type AS string)       AS file_type
    , CAST(class_name AS string)      AS class_name
FROM {{ source('source_tms', 'raw_report_template') }}