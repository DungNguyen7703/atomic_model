/*
*--------------------------------------------------------------------*
* Program code: stg_tms_case_file_assignment
* Program name: Staging TMS.CASE_FILE_ASSIGNMENT
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
    , CAST(case_file_id AS string)     AS case_file_id
    , CAST(assignee_id AS string)      AS assignee_id
    , CAST(assignee_name AS string)    AS assignee_name
    , CAST(assignee_role AS int)       AS assignee_role
    , CAST(deputy_kind AS int)         AS deputy_kind
    , CAST(assign_source AS int)       AS assign_source
    , CAST(assigned_by_id AS string)   AS assigned_by_id
    , CAST(assigned_by_name AS string) AS assigned_by_name
    , CAST(assigned_at AS timestamp)   AS assigned_at
    , CAST(state AS int)               AS state
    , CAST(revoked_at AS timestamp)    AS revoked_at
    , CAST(revoked_by_id AS string)    AS revoked_by_id
    , CAST(revoked_by_name AS string)  AS revoked_by_name
    , CAST(revoke_reason AS string)    AS revoke_reason
    , CAST(approval_step_id AS string) AS approval_step_id
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
    , CAST(version AS int)             AS version
FROM {{ source('source_tms', 'raw_case_file_assignment') }}