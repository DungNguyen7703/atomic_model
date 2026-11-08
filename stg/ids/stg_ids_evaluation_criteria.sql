/*
*--------------------------------------------------------------------*
* Program code: stg_ids_evaluation_criteria
* Program name: Staging IDS.EVALUATION_CRITERIA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(group_id AS int)               AS group_id
    , CAST(criterion_name AS string)      AS criterion_name
    , CAST(criterion_cd AS string)        AS criterion_cd
    , CAST(description AS string)         AS description
    , CAST(subgroup_name AS string)       AS subgroup_name
    , CAST(group_cd AS string)            AS group_cd
    , CAST(basic_flg AS int)              AS basic_flg
    , CAST(display_order_group AS int)    AS display_order_group
    , CAST(display_order_subgroup AS int) AS display_order_subgroup
    , CAST(created_by AS string)          AS created_by
    , CAST(created_date AS date)          AS created_date
    , CAST(updated_by AS string)          AS updated_by
    , CAST(updated_date AS date)          AS updated_date
FROM {{ source('source_ids', 'raw_evaluation_criteria') }}