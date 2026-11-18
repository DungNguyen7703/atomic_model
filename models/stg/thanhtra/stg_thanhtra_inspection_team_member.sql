/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_team_member
* Program name: Staging THANHTRA.INSPECTION_TEAM_MEMBER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_INSPECTION_TEAM_MEMBER.yaml] them cot job_title (cuoi, sau deleted).
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                   AS id
    , CAST(inspection_team_id AS string) AS inspection_team_id
    , CAST(user_id AS string)            AS user_id
    , CAST(user_full_name AS string)     AS user_full_name
    , CAST(user_account AS string)       AS user_account
    , CAST(department_id AS string)      AS department_id
    , CAST(department_name AS string)    AS department_name
    , CAST(role_in_team AS string)       AS role_in_team
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)         AS created_by
    , CAST(last_modified_by AS string)   AS last_modified_by
    , CAST(version AS bigint)            AS version
    , CAST(deleted AS int)               AS deleted
    , CAST(job_title AS string) AS job_title
FROM {{ source('source_thanhtra', 'raw_inspection_team_member') }}