/*
*--------------------------------------------------------------------*
* Program code: stg_tms_abnormal_report_config
* Program name: Staging TMS.ABNORMAL_REPORT_CONFIG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(form_template_id AS string) AS form_template_id
    , CAST(column_code AS string)      AS column_code
    , CAST(column_label AS string)     AS column_label
    , CAST(data_type AS string)        AS data_type
    , CAST(display_order AS int)       AS display_order
    , CAST(is_required AS int)         AS is_required
    , CAST(is_visible AS int)          AS is_visible
    , CAST(validation_rule AS string)  AS validation_rule
    , CAST(description AS string)      AS description
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_tms', 'raw_abnormal_report_config') }}