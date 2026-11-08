/*
*--------------------------------------------------------------------*
* Program code: atm_pc_state_capital
* Program name: Atomic Public Company State Capital
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH st_ca AS (
    SELECT
        id
        , company_profile_id
        , state_rep_name_vi
        , state_rep_name_en
        , state_owner_org_vi
        , state_owner_org_en
        , owned_share_qty
        , ownership_ratio
        , delete_flg
    FROM {{ ref('ods_ids_state_capital') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_STATE_CAPITAL', "st_ca.id") }}                      AS pc_state_capital_id
    , CAST(st_ca.id AS string)                                                                AS pc_state_capital_code
    , CAST('IDS_STATE_CAPITAL' AS string)                                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "st_ca.company_profile_id") }} AS pc_id
    , CAST(st_ca.company_profile_id AS string)                                                AS pc_code
    , CAST(st_ca.state_rep_name_vi AS string)                                                 AS state_representative_nm
    , CAST(st_ca.state_rep_name_en AS string)                                                 AS state_representative_english_nm
    , CAST(st_ca.state_owner_org_vi AS string)                                                AS state_owner_organization_nm
    , CAST(st_ca.state_owner_org_en AS string)                                                AS state_owner_organization_english_nm
    , CAST(st_ca.owned_share_qty AS int)                                                      AS owned_share_quantity
    , CAST(st_ca.ownership_ratio AS decimal(5,2))                                             AS ownership_ratio_percentage
    , CAST(st_ca.delete_flg AS int)                                                           AS deleted_indicator
FROM st_ca