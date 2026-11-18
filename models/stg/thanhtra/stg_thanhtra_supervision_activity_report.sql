/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_supervision_activity_report
* Program name: Staging THANHTRA.SUPERVISION_ACTIVITY_REPORT
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
    , CAST(unit_id AS string)             AS unit_id
    , CAST(unit_name AS string)           AS unit_name
    , CAST(title AS string)               AS title
    , CAST(period_type AS string)         AS period_type
    , CAST(period_value AS int)           AS period_value
    , CAST(report_year AS int)            AS report_year
    , CAST(content AS string)             AS content
    , CAST(status AS string)              AS status
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
    , CAST(created_by_ban_role AS string) AS created_by_ban_role
FROM {{ source('source_thanhtra', 'raw_supervision_activity_report') }}