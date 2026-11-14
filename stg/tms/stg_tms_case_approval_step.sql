/*
*--------------------------------------------------------------------*
* Program code: stg_tms_case_approval_step
* Program name: Staging TMS.CASE_APPROVAL_STEP
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo TMS_ddl_prod.sql, brd_TMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot); yml append/None -> snapshot/ds_snpst_dt theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(case_file_id AS string)          AS case_file_id
    , CAST(step_code AS int)                AS step_code
    , CAST(step_name AS string)             AS step_name
    , CAST(assigned_user_id AS string)      AS assigned_user_id
    , CAST(assigned_role AS string)         AS assigned_role
    , CAST(status AS int)                   AS status
    , CAST(action_at AS timestamp)          AS action_at
    , CAST(action_note AS string)           AS action_note
    , CAST(next_step_code AS int)           AS next_step_code
    , CAST(next_assigned_user_id AS string) AS next_assigned_user_id
    , CAST(next_assigned_role AS string)    AS next_assigned_role
    , CAST(due_date AS timestamp)           AS due_date
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(created_by_id AS string)         AS created_by_id
    , CAST(updated_by_id AS string)         AS updated_by_id
    , CAST(created_by_name AS string)       AS created_by_name
    , CAST(updated_by_name AS string)       AS updated_by_name
    , CAST(deleted AS int)                  AS deleted
    , CAST(version AS bigint)               AS version
    , CAST(action_by_user_id AS string)     AS action_by_user_id
FROM {{ source('source_tms', 'raw_case_approval_step') }}