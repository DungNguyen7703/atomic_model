/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_assignment_notification
* Program name: Staging TMS.REPORT_ASSIGNMENT_NOTIFICATION
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
    , CAST(report_assignment_id AS string) AS report_assignment_id
    , CAST(notification_type AS int)       AS notification_type
    , CAST(title AS string)                AS title
    , CAST(content AS string)              AS content
    , CAST(recipient_user_id AS string)    AS recipient_user_id
    , CAST(recipient_email AS string)      AS recipient_email
    , CAST(sent_at AS timestamp)           AS sent_at
    , CAST(send_status AS int)             AS send_status
    , CAST(send_error AS string)           AS send_error
    , CAST(read_status AS int)             AS read_status
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(updated_at AS timestamp)        AS updated_at
    , CAST(created_by_id AS string)        AS created_by_id
    , CAST(updated_by_id AS string)        AS updated_by_id
    , CAST(created_by_name AS string)      AS created_by_name
    , CAST(updated_by_name AS string)      AS updated_by_name
    , CAST(deleted AS int)                 AS deleted
FROM {{ source('source_tms', 'raw_report_assignment_notification') }}