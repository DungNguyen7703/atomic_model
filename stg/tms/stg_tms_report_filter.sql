/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_filter
* Program name: Staging TMS.REPORT_FILTER
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
    , CAST(template_id AS string)     AS template_id
    , CAST(attribute_id AS string)    AS attribute_id
    , CAST(filter_type AS string)     AS filter_type
    , CAST(operator AS string)        AS operator
    , CAST(default_value AS string)   AS default_value
    , CAST(is_required AS int)        AS is_required
    , CAST(filter_order AS int)       AS filter_order
    , CAST(note AS string)            AS note
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_report_filter') }}