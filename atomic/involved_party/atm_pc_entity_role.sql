/*
*--------------------------------------------------------------------*
* Program code: atm_pc_entity_role
* Program name: Atomic Public Company Entity Role
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH co_en_ro AS (
    SELECT
        id
        , company_profile_id
        , legal_entity_id
        , role_type_cd
        , effective_from_date
        , effective_to_date
    FROM {{ ref('ods_ids_company_entity_role') }}
    WHERE delete_flg = 0
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_ENTITY_ROLE', "co_en_ro.id") }}                AS pc_entity_role_id
    , CAST(co_en_ro.id AS string)                                                                AS pc_entity_role_code
    , CAST('IDS_COMPANY_ENTITY_ROLE' AS string)                                                  AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "co_en_ro.company_profile_id") }} AS pc_id
    , CAST(co_en_ro.company_profile_id AS string)                                                AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "co_en_ro.legal_entity_id") }}      AS legal_entity_id
    , CAST(co_en_ro.legal_entity_id AS string)                                                   AS legal_entity_code
    , CAST(co_en_ro.role_type_cd AS string)                                                      AS role_tp_code
    , CAST(co_en_ro.effective_from_date AS date)                                                 AS effective_from_dt
    , CAST(co_en_ro.effective_to_date AS date)                                                   AS effective_to_dt
FROM co_en_ro