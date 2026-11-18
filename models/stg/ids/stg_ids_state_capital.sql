/*
*--------------------------------------------------------------------*
* Program code: stg_ids_state_capital
* Program name: Staging IDS.STATE_CAPITAL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(company_profile_id AS int)       AS company_profile_id
    , CAST(state_rep_name_vi AS string)     AS state_rep_name_vi
    , CAST(state_rep_name_en AS string)     AS state_rep_name_en
    , CAST(owned_share_qty AS int)          AS owned_share_qty
    , CAST(ownership_ratio AS decimal(5,2)) AS ownership_ratio
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS date)            AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS date)            AS updated_date
    , CAST(delete_flg AS int)               AS delete_flg
    , CAST(state_owner_org_vi AS string)    AS state_owner_org_vi
    , CAST(state_owner_org_en AS string)    AS state_owner_org_en
FROM {{ source('source_ids', 'raw_state_capital') }}