/*
*--------------------------------------------------------------------*
* Program code: atm_pc_related_entity
* Program name: Atomic Pc Related Entity
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
        , company_profile_id
        , relationship_type_cd
        , full_name_vi
        , full_name_en
        , related_party_info
        , paid_in_capital
        , owned_share_qty
        , effective_from_date
        , effective_to_date
        , ownership_ratio
        , voting_share_ratio
    FROM {{ ref('ods_ids_company_relationship') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_RELATIONSHIP', "id") }}               AS pc_related_entity_id
    , CAST(id AS string)                                                                AS pc_related_entity_code
    , CAST('IDS_COMPANY_RELATIONSHIP' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(relationship_type_cd AS string)                                              AS rltnp_tp_code
    , CAST(full_name_vi AS string)                                                      AS related_entity_nm
    , CAST(full_name_en AS string)                                                      AS related_entity_english_nm
    , CAST(related_party_info AS string)                                                AS related_party_information
    , CAST(paid_in_capital AS decimal(23,2))                                            AS related_entity_charter_capital_amt
    , CAST(owned_share_qty AS bigint)                                                   AS owned_share_quantity
    , CAST(ownership_ratio AS decimal(5,2))                                             AS ownership_ratio_percentage
    , CAST(voting_share_ratio AS decimal(5,2))                                          AS voting_share_ratio_percentage
    , CAST(effective_from_date AS date)                                                 AS effective_from_dt
    , CAST(effective_to_date AS date)                                                   AS effective_to_dt
FROM src
