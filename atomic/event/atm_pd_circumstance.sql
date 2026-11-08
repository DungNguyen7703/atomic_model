/*
*--------------------------------------------------------------------*
* Program code: atm_pd_circumstance
* Program name: Atomic Penalty Decision Circumstance
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD THANHTRA_PENALTY_DECISION_CIRCUMSTANCE.
*--------------------------------------------------------------------*
*/

WITH pe_de_ci AS (
    SELECT
        id
        , penalty_decision_subject_behavior_id
        , circumstance_type
    FROM {{ ref('ods_thanhtra_penalty_decision_circumstance') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_CIRCUMSTANCE', "pe_de_ci.id") }}                                       AS pd_circumstance_id
    , CAST(pe_de_ci.id AS string)                                                                                                        AS pd_circumstance_code
    , CAST('THANHTRA_PENALTY_DECISION_CIRCUMSTANCE' AS string)                                                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR', "pe_de_ci.penalty_decision_subject_behavior_id") }} AS pd_subject_behavior_id
    , CAST(pe_de_ci.penalty_decision_subject_behavior_id AS string)                                                                      AS pd_subject_behavior_code
    , CAST(pe_de_ci.circumstance_type AS string)                                                                                         AS circumstance_tp_code
FROM pe_de_ci