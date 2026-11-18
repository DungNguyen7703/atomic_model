/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_examination_team_member
* Program name: Staging THANHTRA.EXAMINATION_TEAM_MEMBER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(examination_team_id AS string) AS examination_team_id
    , CAST(user_id AS string)             AS user_id
    , CAST(user_full_name AS string)      AS user_full_name
    , CAST(user_account AS string)        AS user_account
    , CAST(department_id AS string)       AS department_id
    , CAST(department_name AS string)     AS department_name
    , CAST(role_in_team AS string)        AS role_in_team
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_thanhtra', 'raw_examination_team_member') }}