/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_decision_subject_behavior_supplementary
* Program name: Staging THANHTRA.PENALTY_DECISION_SUBJECT_BEHAVIOR_SUPPLEMENTARY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-08
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-08		tuan.nguyenvanb		[MOI] Bo sung STG theo THANHTRA_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                   AS id
    , CAST(penalty_decision_subject_behavior_id AS string) AS penalty_decision_subject_behavior_id
    , CAST(penalty_type_id AS string)                      AS penalty_type_id
    , CAST(created_at AS timestamp)                        AS created_at
    , CAST(last_modified_at AS timestamp)                  AS last_modified_at
    , CAST(created_by AS string)                           AS created_by
    , CAST(last_modified_by AS string)                     AS last_modified_by
    , CAST(version AS bigint)                              AS version
    , CAST(deleted AS int)                                 AS deleted
FROM {{ source('source_thanhtra', 'raw_penalty_decision_subject_behavior_supplementary') }}