/*
*--------------------------------------------------------------------*
* Program code: stg_tms_computed_column
* Program name: Staging TMS.COMPUTED_COLUMN
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(template_id AS string)         AS template_id
    , CAST(col_name AS string)            AS col_name
    , CAST(formula AS string)             AS formula
    , CAST(left_report_col_id AS string)  AS left_report_col_id
    , CAST(right_report_col_id AS string) AS right_report_col_id
    , CAST(display_order AS int)          AS display_order
    , CAST(format_pattern AS string)      AS format_pattern
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_by_name AS string)     AS updated_by_name
    , CAST(deleted AS int)                AS deleted
    , CAST(attribute_id AS string)        AS attribute_id
    , CAST(expression AS string)          AS expression
FROM {{ source('source_tms', 'raw_computed_column') }}