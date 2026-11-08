/*
*--------------------------------------------------------------------*
* Program code: stg_ids_bond_listing
* Program name: Staging IDS.BOND_LISTING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                               AS id
    , CAST(company_profile_id AS int)               AS company_profile_id
    , CAST(company_name AS string)                  AS company_name
    , CAST(enterprise_type AS string)               AS enterprise_type
    , CAST(industry AS string)                      AS industry
    , CAST(bond_ticker AS string)                   AS bond_ticker
    , CAST(bond_type_cd AS string)                  AS bond_type_cd
    , CAST(decision_no AS string)                   AS decision_no
    , CAST(decision_date AS date)                   AS decision_date
    , CAST(offering_qty AS decimal(19,0))           AS offering_qty
    , CAST(par_value AS int)                        AS par_value
    , CAST(coupon_rate AS decimal(5,2))             AS coupon_rate
    , CAST(issuance_start_date AS date)             AS issuance_start_date
    , CAST(issuance_end_date AS date)               AS issuance_end_date
    , CAST(first_trading_date AS date)              AS first_trading_date
    , CAST(maturity_date AS date)                   AS maturity_date
    , CAST(issuance_category_cd AS string)          AS issuance_category_cd
    , CAST(currency AS string)                      AS currency
    , CAST(announcement_date AS date)               AS announcement_date
    , CAST(issuance_market AS string)               AS issuance_market
    , CAST(tenor_unit AS string)                    AS tenor_unit
    , CAST(tenor AS string)                         AS tenor
    , CAST(remaining_tenor AS int)                  AS remaining_tenor
    , CAST(buyback_and_swap_terms AS string)        AS buyback_and_swap_terms
    , CAST(coupon_payment_type AS string)           AS coupon_payment_type
    , CAST(interest_type AS string)                 AS interest_type
    , CAST(coupon_payment_method AS string)         AS coupon_payment_method
    , CAST(credit_rating_agency AS string)          AS credit_rating_agency
    , CAST(latest_credit_rating AS string)          AS latest_credit_rating
    , CAST(independent_evaluation_agency AS string) AS independent_evaluation_agency
    , CAST(collateral_agent AS string)              AS collateral_agent
    , CAST(created_by AS string)                    AS created_by
    , CAST(created_date AS date)                    AS created_date
    , CAST(updated_by AS string)                    AS updated_by
    , CAST(updated_date AS date)                    AS updated_date
    , CAST(delete_flg AS int)                       AS delete_flg
FROM {{ source('source_ids', 'raw_bond_listing') }}