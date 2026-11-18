/*
*--------------------------------------------------------------------*
* Program code: stg_ids_securities_offering_plan
* Program name: Staging IDS.SECURITIES_OFFERING_PLAN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                 AS id
    , CAST(securities_offering_id AS bigint)           AS securities_offering_id
    , CAST(offering_method_cd AS string)               AS offering_method_cd
    , CAST(distribution_method_cd AS string)           AS distribution_method_cd
    , CAST(security_type_cd AS string)                 AS security_type_cd
    , CAST(security_name AS string)                    AS security_name
    , CAST(par_value AS bigint)                        AS par_value
    , CAST(total_registered_qty AS bigint)             AS total_registered_qty
    , CAST(offering_price AS int)                      AS offering_price
    , CAST(total_expected_am AS decimal(19,0))         AS total_expected_am
    , CAST(issuer_total_registered_qty AS bigint)      AS issuer_total_registered_qty
    , CAST(shareholder_registered_qty AS bigint)       AS shareholder_registered_qty
    , CAST(issuer_total_expected_am AS decimal(19,0))  AS issuer_total_expected_am
    , CAST(shareholder_expected_am AS decimal(19,0))   AS shareholder_expected_am
    , CAST(offering_start_date AS date)                AS offering_start_date
    , CAST(offering_end_date AS date)                  AS offering_end_date
    , CAST(owned_share_qty AS bigint)                  AS owned_share_qty
    , CAST(unrestricted_share_qty AS bigint)           AS unrestricted_share_qty
    , CAST(offer_to_owned_pct AS decimal(5,2))         AS offer_to_owned_pct
    , CAST(transfer_restrict_period AS string)         AS transfer_restrict_period
    , CAST(offer_success_pct AS decimal(5,2))          AS offer_success_pct
    , CAST(offer_to_outstanding_pct AS decimal(5,2))   AS offer_to_outstanding_pct
    , CAST(employee_qty AS int)                        AS employee_qty
    , CAST(capital_source AS string)                   AS capital_source
    , CAST(exercise_period AS string)                  AS exercise_period
    , CAST(rights_ratio AS string)                     AS rights_ratio
    , CAST(swap_ratio AS string)                       AS swap_ratio
    , CAST(swap_target AS string)                      AS swap_target
    , CAST(issuance_market AS string)                  AS issuance_market
    , CAST(interest_rate AS decimal(5,2))              AS interest_rate
    , CAST(bond_term_value AS string)                  AS bond_term_value
    , CAST(interest_payment_period AS string)          AS interest_payment_period
    , CAST(conversion_period_value AS string)          AS conversion_period_value
    , CAST(conversion_ratio AS decimal(6,2))           AS conversion_ratio
    , CAST(conversion_guarantee_plan AS string)        AS conversion_guarantee_plan
    , CAST(exercise_period_value AS string)            AS exercise_period_value
    , CAST(exercise_ratio AS decimal(6,2))             AS exercise_ratio
    , CAST(exercise_guarantee_plan AS string)          AS exercise_guarantee_plan
    , CAST(guarantee_type_cd AS string)                AS guarantee_type_cd
    , CAST(guaranteed_bond_value AS decimal(24,2))     AS guaranteed_bond_value
    , CAST(payment_guarantor_org AS string)            AS payment_guarantor_org
    , CAST(payment_guarantee_value AS decimal(24,2))   AS payment_guarantee_value
    , CAST(secured_asset AS string)                    AS secured_asset
    , CAST(secured_asset_value AS decimal(24,2))       AS secured_asset_value
    , CAST(secured_asset_owner AS string)              AS secured_asset_owner
    , CAST(secured_asset_org AS string)                AS secured_asset_org
    , CAST(public_offering_val AS decimal(19,0))       AS public_offering_val
    , CAST(private_placement_val AS decimal(19,0))     AS private_placement_val
    , CAST(total_outstanding_val AS decimal(19,0))     AS total_outstanding_val
    , CAST(public_offering_12m_val AS decimal(19,0))   AS public_offering_12m_val
    , CAST(private_placement_12m_val AS decimal(19,0)) AS private_placement_12m_val
    , CAST(total_12m_val AS decimal(19,0))             AS total_12m_val
    , CAST(reg_to_outstanding_pct AS decimal(5,2))     AS reg_to_outstanding_pct
    , CAST(created_by AS string)                       AS created_by
    , CAST(created_date AS date)                       AS created_date
    , CAST(updated_by AS string)                       AS updated_by
    , CAST(updated_date AS date)                       AS updated_date
    , CAST(delete_flg AS int)                          AS delete_flg
    , CAST(plan_single_obj AS string)                  AS plan_single_obj
FROM {{ source('source_ids', 'raw_securities_offering_plan') }}