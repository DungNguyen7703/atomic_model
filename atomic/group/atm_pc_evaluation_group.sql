/*
*--------------------------------------------------------------------*
* Program code: atm_pc_evaluation_group
* Program name: Atomic Public Company Evaluation Group
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ev_gr AS (
    SELECT
        group_cd
        , group_name
        , description
        , weight
        , display_order
    FROM {{ ref('ods_ids_evaluation_groups') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_EVALUATION_GROUPS', "ev_gr.group_cd") }} AS pc_evaluation_group_id
    , CAST(ev_gr.group_cd AS string)                                               AS pc_evaluation_group_code
    , CAST('IDS_EVALUATION_GROUPS' AS string)                                      AS src_stm_code
    , CAST(ev_gr.group_name AS string)                                             AS pc_evaluation_group_nm
    , CAST(ev_gr.description AS string)                                            AS description
    , CAST(ev_gr.weight AS decimal(5,2))                                           AS weight_percentage
    , CAST(ev_gr.display_order AS int)                                             AS display_order
FROM ev_gr