/*
*--------------------------------------------------------------------*
* Program code: stg_ids_holder_relationship
* Program name: Staging IDS.HOLDER_RELATIONSHIP
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(relationship_type_cd AS string) AS relationship_type_cd
    , CAST(legal_entity_id AS int)         AS legal_entity_id
    , CAST(related_entity_id AS int)       AS related_entity_id
    , CAST(effective_from_date AS date)    AS effective_from_date
    , CAST(effective_to_date AS date)      AS effective_to_date
    , CAST(active_flg AS int)              AS active_flg
    , CAST(relationship_reason AS string)  AS relationship_reason
    , CAST(remarks AS string)              AS remarks
    , CAST(created_by AS string)           AS created_by
    , CAST(created_date AS date)           AS created_date
    , CAST(updated_by AS string)           AS updated_by
    , CAST(updated_date AS date)           AS updated_date
    , CAST(delete_flg AS int)              AS delete_flg
FROM {{ source('source_ids', 'raw_holder_relationship') }}