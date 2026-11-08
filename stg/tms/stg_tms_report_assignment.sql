/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_assignment
* Program name: Staging TMS.REPORT_ASSIGNMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(report_id AS string)         AS report_id
    , CAST(report_type AS int)          AS report_type
    , CAST(assignment_type AS int)      AS assignment_type
    , CAST(assignee_id AS string)       AS assignee_id
    , CAST(assignee_name AS string)     AS assignee_name
    , CAST(assignee_title AS string)    AS assignee_title
    , CAST(assigned_by_id AS string)    AS assigned_by_id
    , CAST(assigned_by_name AS string)  AS assigned_by_name
    , CAST(assigned_by_title AS string) AS assigned_by_title
    , CAST(assigned_date AS timestamp)  AS assigned_date
    , CAST(revoked_date AS timestamp)   AS revoked_date
    , CAST(revoked_by_id AS string)     AS revoked_by_id
    , CAST(revoked_by_name AS string)   AS revoked_by_name
    , CAST(status AS int)               AS status
    , CAST(notification_sent AS int)    AS notification_sent
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
    , CAST(revoked_by_title AS string)  AS revoked_by_title
FROM {{ source('source_tms', 'raw_report_assignment') }}