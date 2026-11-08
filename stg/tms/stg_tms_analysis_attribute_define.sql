/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_attribute_define
* Program name: Staging TMS.ANALYSIS_ATTRIBUTE_DEFINE
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
    , CAST(attribute_code AS string)  AS attribute_code
    , CAST(attribute_name AS string)  AS attribute_name
    , CAST(description AS string)     AS description
    , CAST(workflow_type AS int)      AS workflow_type
    , CAST(data_type AS string)       AS data_type
    , CAST(default_value AS string)   AS default_value
    , CAST(min_value AS string)       AS min_value
    , CAST(max_value AS string)       AS max_value
    , CAST(unit AS string)            AS unit
    , CAST(step AS string)            AS step
    , CAST(display_group AS string)   AS display_group
    , CAST(display_order AS int)      AS display_order
    , CAST(active_flag AS int)        AS active_flag
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(version AS int)            AS version
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_analysis_attribute_define') }}