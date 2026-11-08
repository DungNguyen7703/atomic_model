/*
*--------------------------------------------------------------------*
* Program code: ods_ids_securities_offering_plan
* Program name: ODS IDS.SECURITIES_OFFERING_PLAN
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
    , securities_offering_id
    , offering_method_cd
    , distribution_method_cd
    , security_type_cd
    , security_name
    , par_value
    , total_registered_qty
    , offering_price
    , total_expected_am
    , issuer_total_registered_qty
    , shareholder_registered_qty
    , issuer_total_expected_am
    , shareholder_expected_am
    , offering_start_date
    , offering_end_date
    , owned_share_qty
    , unrestricted_share_qty
    , offer_to_owned_pct
    , transfer_restrict_period
    , offer_success_pct
    , offer_to_outstanding_pct
    , employee_qty
    , capital_source
    , exercise_period
    , rights_ratio
    , swap_ratio
    , swap_target
    , issuance_market
    , interest_rate
    , bond_term_value
    , interest_payment_period
    , conversion_period_value
    , conversion_ratio
    , conversion_guarantee_plan
    , exercise_period_value
    , exercise_ratio
    , exercise_guarantee_plan
    , guarantee_type_cd
    , guaranteed_bond_value
    , payment_guarantor_org
    , payment_guarantee_value
    , secured_asset
    , secured_asset_value
    , secured_asset_owner
    , secured_asset_org
    , public_offering_val
    , private_placement_val
    , total_outstanding_val
    , public_offering_12m_val
    , private_placement_12m_val
    , total_12m_val
    , reg_to_outstanding_pct
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , plan_single_obj
FROM {{ ref('stg_ids_securities_offering_plan') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')