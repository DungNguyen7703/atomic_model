/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_adhoc_admin_violation_report
* Program name: Staging THANHTRA.ADHOC_ADMIN_VIOLATION_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(name AS string)             AS name
    , CAST(report_type AS string)      AS report_type
    , CAST(requesting_unit AS string)  AS requesting_unit
    , CAST(period_from AS date)        AS period_from
    , CAST(period_to AS date)          AS period_to
    , CAST(content AS string)          AS content
    , CAST(note AS string)             AS note
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
    , CAST(status AS string)           AS status
FROM {{ source('source_thanhtra', 'raw_adhoc_admin_violation_report') }}