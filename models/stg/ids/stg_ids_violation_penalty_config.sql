/*
*--------------------------------------------------------------------*
* Program code: stg_ids_violation_penalty_config
* Program name: Staging IDS.VIOLATION_PENALTY_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(violation_template_id AS int) AS violation_template_id
    , CAST(overdue_days AS int)          AS overdue_days
    , CAST(min_overdue_days AS int)      AS min_overdue_days
    , CAST(max_overdue_days AS int)      AS max_overdue_days
    , CAST(para_cd AS string)            AS para_cd
    , CAST(action_type_cd AS string)     AS action_type_cd
    , CAST(description AS string)        AS description
    , CAST(effective_start_date AS date) AS effective_start_date
    , CAST(effective_end_date AS date)   AS effective_end_date
    , CAST(active_flg AS int)            AS active_flg
    , CAST(delete_flg AS int)            AS delete_flg
    , CAST(created_date AS timestamp)    AS created_date
    , CAST(created_by AS string)         AS created_by
    , CAST(updated_date AS timestamp)    AS updated_date
    , CAST(updated_by AS string)         AS updated_by
FROM {{ source('source_ids', 'raw_violation_penalty_config') }}