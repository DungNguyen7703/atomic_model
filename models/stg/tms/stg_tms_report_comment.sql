/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_comment
* Program name: Staging TMS.REPORT_COMMENT
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
    , CAST(report_id AS string)       AS report_id
    , CAST(report_type AS int)        AS report_type
    , CAST(commenter_id AS string)    AS commenter_id
    , CAST(commenter_name AS string)  AS commenter_name
    , CAST(department_name AS string) AS department_name
    , CAST(content AS string)         AS content
    , CAST(comment_date AS timestamp) AS comment_date
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_report_comment') }}