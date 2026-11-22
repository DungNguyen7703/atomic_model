/*
*--------------------------------------------------------------------*
* Program code: atm_stock_holder_relationship
* Program name: Atomic Stock Holder Relationship
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , relationship_type_cd
        , legal_entity_id
        , related_entity_id
        , effective_from_date
        , effective_to_date
        , relationship_reason
        , remarks
        , relationship_start_date
        , relationship_end_date
    FROM {{ ref('ods_ids_holder_relationship') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_HOLDER_RELATIONSHIP', "id") }}             AS stock_holder_rltnp_id
    , CAST(id AS string)                                                             AS stock_holder_rltnp_code
    , CAST('IDS_HOLDER_RELATIONSHIP' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "legal_entity_id") }}   AS legal_entity_id
    , CAST(legal_entity_id AS string)                                                AS legal_entity_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "related_entity_id") }} AS related_legal_entity_id
    , CAST(related_entity_id AS string)                                              AS related_legal_entity_code
    , CAST(relationship_type_cd AS string)                                           AS rltnp_tp_code
    , CAST(effective_from_date AS date)                                              AS effective_from_dt
    , CAST(effective_to_date AS date)                                                AS effective_to_dt
    , CAST(relationship_reason AS string)                                            AS rltnp_reason
    , CAST(relationship_start_date AS date)                                          AS rltnp_start_dt
    , CAST(relationship_end_date AS date)                                            AS rltnp_end_dt
    , CAST(remarks AS string)                                                        AS remarks
FROM src
