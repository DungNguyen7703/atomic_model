/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_parameter
* Program name: Staging TMS.REPORT_PARAMETER
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
    , CAST(param_code AS string)       AS param_code
    , CAST(param_name AS string)       AS param_name
    , CAST(parent_id AS string)        AS parent_id
    , CAST(param_level AS int)         AS param_level
    , CAST(threshold_type AS int)      AS threshold_type
    , CAST(min_value AS decimal(20,4)) AS min_value
    , CAST(max_value AS decimal(20,4)) AS max_value
    , CAST(display_order AS int)       AS display_order
    , CAST(status AS int)              AS status
    , CAST(notes AS string)            AS notes
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_tms', 'raw_report_parameter') }}