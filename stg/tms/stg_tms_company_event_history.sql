/*
*--------------------------------------------------------------------*
* Program code: stg_tms_company_event_history
* Program name: Staging TMS.COMPANY_EVENT_HISTORY
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
    , CAST(company_event_id AS string) AS company_event_id
    , CAST(change_date AS timestamp)   AS change_date
    , CAST(change_type AS string)      AS change_type
    , CAST(old_value AS string)        AS old_value
    , CAST(new_value AS string)        AS new_value
    , CAST(change_source AS string)    AS change_source
    , CAST(changed_by AS string)       AS changed_by
    , CAST(approval_status AS int)     AS approval_status
    , CAST(approval_comment AS string) AS approval_comment
    , CAST(approved_by_id AS string)   AS approved_by_id
    , CAST(approved_by_name AS string) AS approved_by_name
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
    , CAST(version AS int)             AS version
FROM {{ source('source_tms', 'raw_company_event_history') }}