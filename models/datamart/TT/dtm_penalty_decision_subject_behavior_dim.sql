/*
*--------------------------------------------------------------------*
* Program code: dtm_penalty_decision_subject_behavior_dim
* Program name: Penalty Decision Subject Behavior Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pd_su_be AS (
    SELECT
        pd_subject_behavior_code,
        violation_behavior_id,
        src_stm_code
    FROM {{ ref('atm_pd_subject_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR'
),

vi_be AS (
    SELECT
        violation_behavior_id,
        violation_behavior_nm
    FROM {{ ref('atm_violation_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR', 'pd_su_be.pd_subject_behavior_code') }} AS string) AS penalty_decision_subject_behavior_dim_id,
    CAST(pd_su_be.pd_subject_behavior_code AS string)                        AS penalty_decision_subject_behavior_code,
    CAST(vi_be.violation_behavior_nm AS string)                              AS violation_behavior_nm,
    CAST(pd_su_be.src_stm_code AS string)                                    AS src_stm_code
FROM pd_su_be
LEFT JOIN vi_be
    ON vi_be.violation_behavior_id = pd_su_be.violation_behavior_id
