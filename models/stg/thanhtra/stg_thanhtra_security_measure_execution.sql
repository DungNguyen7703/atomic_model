/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_security_measure_execution
* Program name: Staging THANHTRA.SECURITY_MEASURE_EXECUTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(security_measure_decision_id AS string) AS security_measure_decision_id
    , CAST(reporter_name AS string)                AS reporter_name
    , CAST(report_date AS date)                    AS report_date
    , CAST(content AS string)                      AS content
    , CAST(execution_result AS string)             AS execution_result
    , CAST(note AS string)                         AS note
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
FROM {{ source('source_thanhtra', 'raw_security_measure_execution') }}