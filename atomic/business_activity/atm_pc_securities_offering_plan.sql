/*
*--------------------------------------------------------------------*
* Program code: atm_pc_securities_offering_plan
* Program name: Atomic Public Company Securities Offering Plan
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH se_of_pl AS (
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
        , delete_flg
        , plan_single_obj
    FROM {{ ref('ods_ids_securities_offering_plan') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_SECURITIES_OFFERING_PLAN', "se_of_pl.id") }}                  AS pc_securities_offering_plan_id
    , CAST(se_of_pl.id AS string)                                                                       AS pc_securities_offering_plan_code
    , CAST('IDS_SECURITIES_OFFERING_PLAN' AS string)                                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_SECURITIES_OFFERING', "se_of_pl.securities_offering_id") }} AS pc_securities_offering_id
    , CAST(se_of_pl.securities_offering_id AS string)                                                   AS pc_securities_offering_code
    , CAST(se_of_pl.offering_method_cd AS string)                                                       AS offering_method_code
    , CAST(se_of_pl.distribution_method_cd AS string)                                                   AS distribution_method_code
    , CAST(se_of_pl.security_type_cd AS string)                                                         AS security_tp_code
    , CAST(se_of_pl.security_name AS string)                                                            AS security_nm
    , CAST(se_of_pl.par_value AS decimal(23,2))                                                         AS par_val
    , CAST(se_of_pl.total_registered_qty AS int)                                                        AS total_registered_quantity_snpst
    , CAST(se_of_pl.offering_price AS decimal(23,2))                                                    AS offering_price
    , CAST(se_of_pl.total_expected_am AS decimal(23,2))                                                 AS total_expected_amt_snpst
    , CAST(se_of_pl.issuer_total_registered_qty AS int)                                                 AS issuer_total_registered_quantity
    , CAST(se_of_pl.shareholder_registered_qty AS int)                                                  AS shareholder_registered_quantity
    , CAST(se_of_pl.issuer_total_expected_am AS decimal(23,2))                                          AS issuer_total_expected_amt
    , CAST(se_of_pl.shareholder_expected_am AS decimal(23,2))                                           AS shareholder_expected_amt
    , CAST(se_of_pl.offering_start_date AS date)                                                        AS offering_start_dt
    , CAST(se_of_pl.offering_end_date AS date)                                                          AS offering_end_dt
    , CAST(se_of_pl.owned_share_qty AS int)                                                             AS owned_share_quantity
    , CAST(se_of_pl.unrestricted_share_qty AS int)                                                      AS unrestricted_share_quantity
    , CAST(se_of_pl.offer_to_owned_pct AS decimal(5,2))                                                 AS offer_to_owned_percentage
    , CAST(se_of_pl.transfer_restrict_period AS string)                                                 AS transfer_restrict_period
    , CAST(se_of_pl.offer_success_pct AS decimal(5,2))                                                  AS offer_success_percentage
    , CAST(se_of_pl.offer_to_outstanding_pct AS decimal(5,2))                                           AS offer_to_outstanding_percentage
    , CAST(se_of_pl.employee_qty AS int)                                                                AS employee_quantity
    , CAST(se_of_pl.capital_source AS string)                                                           AS capital_src
    , CAST(se_of_pl.exercise_period AS string)                                                          AS exercise_period
    , CAST(se_of_pl.rights_ratio AS string)                                                             AS rights_ratio
    , CAST(se_of_pl.swap_ratio AS string)                                                               AS swap_ratio
    , CAST(se_of_pl.swap_target AS string)                                                              AS swap_target
    , CAST(se_of_pl.issuance_market AS string)                                                          AS issuance_market
    , CAST(se_of_pl.interest_rate AS decimal(8,5))                                                      AS interest_rate
    , CAST(se_of_pl.bond_term_value AS string)                                                          AS bond_term_val
    , CAST(se_of_pl.interest_payment_period AS string)                                                  AS interest_payment_period
    , CAST(se_of_pl.conversion_period_value AS string)                                                  AS conversion_period_val
    , CAST(se_of_pl.conversion_ratio AS decimal(5,2))                                                   AS conversion_ratio_percentage
    , CAST(se_of_pl.conversion_guarantee_plan AS string)                                                AS conversion_guarantee_plan
    , CAST(se_of_pl.exercise_period_value AS string)                                                    AS exercise_period_val
    , CAST(se_of_pl.exercise_ratio AS decimal(5,2))                                                     AS exercise_ratio_percentage
    , CAST(se_of_pl.exercise_guarantee_plan AS string)                                                  AS exercise_guarantee_plan
    , CAST(se_of_pl.guarantee_type_cd AS string)                                                        AS guarantee_tp_code
    , CAST(se_of_pl.guaranteed_bond_value AS decimal(23,2))                                             AS guaranteed_bond_val
    , CAST(se_of_pl.payment_guarantor_org AS string)                                                    AS payment_guarantor_organization_nm
    , CAST(se_of_pl.payment_guarantee_value AS decimal(23,2))                                           AS payment_guarantee_val
    , CAST(se_of_pl.secured_asset AS string)                                                            AS secured_asset
    , CAST(se_of_pl.secured_asset_value AS decimal(23,2))                                               AS secured_asset_val
    , CAST(se_of_pl.secured_asset_owner AS string)                                                      AS secured_asset_owner
    , CAST(se_of_pl.secured_asset_org AS string)                                                        AS secured_asset_organization_nm
    , CAST(se_of_pl.public_offering_val AS decimal(23,2))                                               AS public_offering_val
    , CAST(se_of_pl.private_placement_val AS decimal(23,2))                                             AS private_placement_val
    , CAST(se_of_pl.total_outstanding_val AS decimal(23,2))                                             AS total_outstanding_val
    , CAST(se_of_pl.public_offering_12m_val AS decimal(23,2))                                           AS public_offering_12_month_val
    , CAST(se_of_pl.private_placement_12m_val AS decimal(23,2))                                         AS private_placement_12_month_val
    , CAST(se_of_pl.total_12m_val AS decimal(23,2))                                                     AS total_12_month_val
    , CAST(se_of_pl.reg_to_outstanding_pct AS decimal(5,2))                                             AS registered_to_outstanding_percentage
    , CAST(se_of_pl.delete_flg AS int)                                                                  AS deleted_indicator
    , CAST(se_of_pl.plan_single_obj AS string)                                                          AS single_offering_object
FROM se_of_pl