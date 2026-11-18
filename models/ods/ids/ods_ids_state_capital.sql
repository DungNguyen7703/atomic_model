/*
*--------------------------------------------------------------------*
* Program code: ods_ids_state_capital
* Program name: ODS IDS.STATE_CAPITAL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , company_profile_id
    , state_rep_name_vi
    , state_rep_name_en
    , owned_share_qty
    , ownership_ratio
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , state_owner_org_vi
    , state_owner_org_en
FROM {{ ref('stg_ids_state_capital') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0