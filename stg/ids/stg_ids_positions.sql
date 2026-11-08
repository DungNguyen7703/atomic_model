/*
*--------------------------------------------------------------------*
* Program code: stg_ids_positions
* Program name: Staging IDS.POSITIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/
SELECT
    CAST(id AS int)                  AS id
    , CAST(position_cd AS string)    AS position_cd
    , CAST(appointment_date AS date) AS appointment_date
    , CAST(dismissal_date AS date)   AS dismissal_date
    , CAST(active_flg AS int)        AS active_flg
    , CAST(legal_entity_id AS int)   AS legal_entity_id
    , CAST(created_by AS string)     AS created_by
    , CAST(created_date AS date)     AS created_date
    , CAST(updated_by AS string)     AS updated_by
    , CAST(updated_date AS date)     AS updated_date
    , CAST(delete_flg AS int)        AS delete_flg
    , CAST(company_profile_id as bigint) as company_profile_id
FROM {{ source('source_ids', 'raw_positions') }}