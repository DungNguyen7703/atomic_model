/*
*--------------------------------------------------------------------*
* Program code: stg_ids_evaluation_groups
* Program name: Staging IDS.EVALUATION_GROUPS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(group_name AS string)   AS group_name
    , CAST(description AS string)  AS description
    , CAST(weight AS decimal(5,2)) AS weight
    , CAST(display_order AS int)   AS display_order
    , CAST(group_cd AS string)     AS group_cd
    , CAST(created_by AS string)   AS created_by
    , CAST(created_date AS date)   AS created_date
    , CAST(updated_by AS string)   AS updated_by
    , CAST(updated_date AS date)   AS updated_date
FROM {{ source('source_ids', 'raw_evaluation_groups') }}