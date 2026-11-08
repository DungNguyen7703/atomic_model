/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_decision_violation_record
* Program name: Staging THANHTRA.PENALTY_DECISION_VIOLATION_RECORD
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
    , CAST(penalty_decision_id AS string) AS penalty_decision_id
    , CAST(violation_record_id AS string) AS violation_record_id
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_thanhtra', 'raw_penalty_decision_violation_record') }}