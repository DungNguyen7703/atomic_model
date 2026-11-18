/*
*--------------------------------------------------------------------*
* Program code: atm_pc_evaluation
* Program name: Atomic Public Company Evaluation
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH eval AS (
    SELECT
        id
        , company_id
        , period_id
        , total_score
        , evaluation_date
        , type
        , status
        , approved_by
        , approved_date
    FROM {{ ref('ods_ids_evaluations') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_EVALUATIONS', "eval.id") }}                 AS pc_evaluation_id
    , CAST(eval.id AS string)                                                         AS pc_evaluation_code
    , CAST('IDS_EVALUATIONS' AS string)                                               AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "eval.company_id") }}  AS pc_id
    , CAST(eval.company_id AS string)                                                 AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_EVALUATION_PERIODS', "eval.period_id") }} AS pc_evaluation_period_id
    , CAST(eval.period_id AS string)                                                  AS pc_evaluation_period_code
    , CAST(eval.total_score AS decimal(5,2))                                          AS total_score_percentage
    , CAST(eval.evaluation_date AS date)                                              AS evaluation_dt
    , CAST(eval.type AS string)                                                       AS evaluation_tp_code
    , CAST(eval.status AS string)                                                     AS evaluation_status_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "eval.approved_by") }}            AS approved_by_user_id
    , CAST(eval.approved_by AS string)                                                AS approved_by_user_code
    , CAST(eval.approved_date AS date)                                                AS approved_dt
FROM eval