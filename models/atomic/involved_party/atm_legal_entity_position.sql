/*
*--------------------------------------------------------------------*
* Program code: atm_legal_entity_position
* Program name: Atomic Legal Entity Position
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH posi AS (
    SELECT
        id
        , legal_entity_id
        , company_profile_id
        , position_cd
        , appointment_date
        , dismissal_date
    FROM {{ ref('ods_ids_positions') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_POSITIONS', "posi.id") }}                          AS legal_entity_position_id
    , CAST(posi.id AS string)                                                                AS legal_entity_position_code
    , CAST('IDS_POSITIONS' AS string)                                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "posi.legal_entity_id") }}      AS legal_entity_id
    , CAST(posi.legal_entity_id AS string)                                                   AS legal_entity_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "posi.company_profile_id") }} AS pc_id
    , CAST(posi.company_profile_id AS string)                                                AS pc_code
    , CAST(posi.position_cd AS string)                                                       AS position_code
    , CAST(posi.appointment_date AS date)                                                    AS appointment_dt
    , CAST(posi.dismissal_date AS date)                                                      AS dismissal_dt
FROM posi