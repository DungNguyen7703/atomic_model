/*
*--------------------------------------------------------------------*
* Program code: stg_ids_bond_listing_history
* Program name: Staging IDS.BOND_LISTING_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(company_profile_id AS int)      AS company_profile_id
    , CAST(bond_ticker AS string)          AS bond_ticker
    , CAST(bond_type_cd AS string)         AS bond_type_cd
    , CAST(decision_no AS string)          AS decision_no
    , CAST(decision_date AS date)          AS decision_date
    , CAST(issuance_qty AS int)            AS issuance_qty
    , CAST(par_value AS int)               AS par_value
    , CAST(coupon_rate AS decimal(7,4))    AS coupon_rate
    , CAST(issuance_start_date AS date)    AS issuance_start_date
    , CAST(issuance_end_date AS date)      AS issuance_end_date
    , CAST(maturity_date AS date)          AS maturity_date
    , CAST(issuance_category_cd AS string) AS issuance_category_cd
    , CAST(created_by AS string)           AS created_by
    , CAST(created_date AS date)           AS created_date
    , CAST(updated_by AS string)           AS updated_by
    , CAST(updated_date AS date)           AS updated_date
    , CAST(is_deleted AS int)              AS is_deleted
    , CAST(is_sync AS int)                 AS is_sync
FROM {{ source('source_ids', 'raw_bond_listing_history') }}
