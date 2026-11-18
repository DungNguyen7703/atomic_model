/*
*--------------------------------------------------------------------*
* Program code: atm_pc_evaluation_detail
* Program name: Atomic Public Company Evaluation Detail
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ev_de AS (
    SELECT
        id
        , evaluation_id
        , criterion_id
        , result
        , score
        , evaluate
    FROM {{ ref('ods_ids_evaluation_details') }}
),

ev_cr AS (
    SELECT
        id
        , criterion_cd
    FROM {{ ref('ods_ids_evaluation_criteria') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_EVALUATION_DETAILS', "ev_de.id") }}              AS pc_evaluation_detail_id
    , CAST(ev_de.id AS string)                                                             AS pc_evaluation_detail_code
    , CAST('IDS_EVALUATION_DETAILS' AS string)                                             AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_EVALUATIONS', "ev_de.evaluation_id") }}        AS pc_evaluation_id
    , CAST(ev_de.evaluation_id AS string)                                                  AS pc_evaluation_code
    , {{ generate_surrogate_key_bigint('IDS_EVALUATION_CRITERIA', "ev_cr.criterion_cd") }} AS pc_evaluation_criterion_id
    , CAST(ev_de.criterion_id AS string)                                                   AS pc_evaluation_criterion_code
    , CAST(ev_de.result AS string)                                                         AS evaluation_result_text
    , CAST(ev_de.score AS int)                                                             AS evaluation_score
    , CAST(ev_de.evaluate AS string)                                                       AS evaluation_level_code
FROM ev_de
    LEFT JOIN ev_cr ON ev_de.CRITERION_ID = ev_cr.ID