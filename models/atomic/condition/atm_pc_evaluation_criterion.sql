/*
*--------------------------------------------------------------------*
* Program code: atm_pc_evaluation_criterion
* Program name: Atomic Public Company Evaluation Criterion IDS.EVALUATION_CRITERIA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ev_cr AS (
    SELECT
        criterion_cd
        , group_cd
        , criterion_name
        , description
        , subgroup_name
        , basic_flg
        , display_order_group
        , display_order_subgroup
    FROM {{ ref('ods_ids_evaluation_criteria') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_EVALUATION_CRITERIA', "ev_cr.criterion_cd") }} AS pc_evaluation_criterion_id
    , CAST(ev_cr.criterion_cd AS string)                                                 AS pc_evaluation_criterion_code
    , CAST('IDS_EVALUATION_CRITERIA' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_EVALUATION_GROUPS', "ev_cr.group_cd") }}     AS pc_evaluation_group_id
    , CAST(ev_cr.group_cd AS string)                                                     AS pc_evaluation_group_code
    , CAST(ev_cr.criterion_name AS string)                                               AS pc_evaluation_criterion_nm
    , CAST(ev_cr.description AS string)                                                  AS description
    , CAST(ev_cr.subgroup_name AS string)                                                AS subgroup_nm
    , CAST(ev_cr.basic_flg AS int)                                                       AS basic_criterion_indicator
    , CAST(ev_cr.display_order_group AS int)                                             AS display_order_group
    , CAST(ev_cr.display_order_subgroup AS int)                                          AS display_order_subgroup
FROM ev_cr