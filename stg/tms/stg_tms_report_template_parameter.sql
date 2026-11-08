/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_template_parameter
* Program name: Staging TMS.REPORT_TEMPLATE_PARAMETER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                   AS id
    , CAST(report_template_id AS string)   AS report_template_id
    , CAST(report_parameter_id AS string)  AS report_parameter_id
    , CAST(param_scope AS int)             AS param_scope
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(deleted AS int)                 AS deleted
    , CAST(param_sce AS int)               AS param_sce
    , CAST(updated_at AS timestamp)        AS updated_at
    , CAST(created_by_id AS string)        AS created_by_id
    , CAST(updated_by_id AS string)        AS updated_by_id
    , CAST(created_by_name AS string)      AS created_by_name
    , CAST(updated_by_name AS string)      AS updated_by_name
    , CAST(attribute_catalog_id AS string) AS attribute_catalog_id
FROM {{ source('source_tms', 'raw_report_template_parameter') }}