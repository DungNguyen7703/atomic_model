/*
*--------------------------------------------------------------------*
* Program code: atm_pd_subject_behavior_x_penalty_type_relationship
* Program name: Atomic Penalty Decision Subject Behavior X Penalty Type Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR_SUPPLEMENTARY.
*--------------------------------------------------------------------*
*/

WITH pe_de_su_be_su AS (
    SELECT
        penalty_decision_subject_behavior_id
        , penalty_type_id
    FROM {{ ref('ods_thanhtra_penalty_decision_subject_behavior_supplementary') }}
),

pt AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_penalty_type') }}
)

SELECT
    CAST('THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR_SUPPLEMENTARY' AS string)                                                               AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR', "pe_de_su_be_su.penalty_decision_subject_behavior_id") }} AS pd_subject_behavior_id
    , CAST(pe_de_su_be_su.penalty_decision_subject_behavior_id AS string)                                                                      AS pd_subject_behavior_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_TYPE', "pt.code") }}                                                                  AS cl_thanhtra_penalty_tp_id
    , CAST(pt.code AS string)                                                                                                                  AS cl_thanhtra_penalty_tp_code
FROM pe_de_su_be_su
    LEFT JOIN pt ON pe_de_su_be_su.penalty_type_id = pt.id