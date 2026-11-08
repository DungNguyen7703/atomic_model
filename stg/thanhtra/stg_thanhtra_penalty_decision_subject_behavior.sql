/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_decision_subject_behavior
* Program name: Staging THANHTRA.PENALTY_DECISION_SUBJECT_BEHAVIOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot); them cot supplementary_penalty.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                            AS id
    , CAST(penalty_decision_subject_id AS string) AS penalty_decision_subject_id
    , CAST(violation_behavior_id AS string)       AS violation_behavior_id
    , CAST(penalty_type_id AS string)             AS penalty_type_id
    , CAST(description AS string)                 AS description
    , CAST(min_fine_amount AS decimal(19,4))      AS min_fine_amount
    , CAST(max_fine_amount AS decimal(19,4))      AS max_fine_amount
    , CAST(applied_fine_amount AS decimal(19,4))  AS applied_fine_amount
    , CAST(remedial_measure AS string)            AS remedial_measure
    , CAST(remedial_deadline AS date)             AS remedial_deadline
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(last_modified_at AS timestamp)         AS last_modified_at
    , CAST(created_by AS string)                  AS created_by
    , CAST(last_modified_by AS string)            AS last_modified_by
    , CAST(version AS bigint)                     AS version
    , CAST(deleted AS int)                        AS deleted
    , CAST(legal_basis AS string)                 AS legal_basis
    , CAST(violation_record_id AS string)         AS violation_record_id
    , CAST(supplementary_penalty AS string)       AS supplementary_penalty
FROM {{ source('source_thanhtra', 'raw_penalty_decision_subject_behavior') }}