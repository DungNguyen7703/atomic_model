/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_entity_role
* Program name: Staging IDS.COMPANY_ENTITY_ROLE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(company_profile_id AS int)   AS company_profile_id
    , CAST(legal_entity_id AS int)      AS legal_entity_id
    , CAST(role_type_cd AS string)      AS role_type_cd
    , CAST(active_flg AS int)           AS active_flg
    , CAST(effective_from_date AS date) AS effective_from_date
    , CAST(effective_to_date AS date)   AS effective_to_date
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
    , CAST(delete_flg AS int)           AS delete_flg
FROM {{ source('source_ids', 'raw_company_entity_role') }}