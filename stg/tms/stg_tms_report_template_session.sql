/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_template_session
* Program name: Staging TMS.REPORT_TEMPLATE_SESSION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(report_template_id AS string) AS report_template_id
    , CAST(session_code AS string)       AS session_code
    , CAST(session_name AS string)       AS session_name
    , CAST(from_time AS string)          AS from_time
    , CAST(to_time AS string)            AS to_time
    , CAST(exchange AS string)           AS exchange
    , CAST(display_order AS int)         AS display_order
    , CAST(deleted AS int)               AS deleted
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(created_by_id AS string)      AS created_by_id
    , CAST(updated_by_id AS string)      AS updated_by_id
    , CAST(created_by_name AS string)    AS created_by_name
    , CAST(updated_by_name AS string)    AS updated_by_name
FROM {{ source('source_tms', 'raw_report_template_session') }}