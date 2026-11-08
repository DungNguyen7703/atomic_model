/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_penalty_decision_subject_behavior
* Program name: ODS THANHTRA.PENALTY_DECISION_SUBJECT_BEHAVIOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , penalty_decision_subject_id
    , violation_behavior_id
    , penalty_type_id
    , description
    , min_fine_amount
    , max_fine_amount
    , applied_fine_amount
    , remedial_measure
    , remedial_deadline
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , legal_basis
    , violation_record_id
FROM {{ ref('stg_thanhtra_penalty_decision_subject_behavior') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0