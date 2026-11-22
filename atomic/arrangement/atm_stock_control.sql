/*
*--------------------------------------------------------------------*
* Program code: atm_stock_control
* Program name: Atomic Stock Control
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
        , restricted_share_qty
        , restriction_start_date
        , restriction_end_date
        , legal_entity_id
        , restriction_type_cd
    FROM {{ ref('ods_ids_stock_controls') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_STOCK_CONTROLS', "id") }}                AS stock_control_id
    , CAST(id AS string)                                                           AS stock_control_code
    , CAST('IDS_STOCK_CONTROLS' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "legal_entity_id") }} AS legal_entity_id
    , CAST(legal_entity_id AS string)                                              AS legal_entity_code
    , CAST(restricted_share_qty AS bigint)                                         AS restricted_share_quantity
    , CAST(restriction_start_date AS date)                                         AS restriction_start_dt
    , CAST(restriction_end_date AS date)                                           AS restriction_end_dt
    , CAST(restriction_type_cd AS string)                                          AS restriction_tp_code
FROM src
