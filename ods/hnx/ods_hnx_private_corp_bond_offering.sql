/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_private_corp_bond_offering
* Program name: ODS HNX.PRIVATE_CORP_BOND_OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(report_month AS string)                 AS report_month
    , CAST(market_type AS string)                AS market_type
    , CAST(posting_date AS date)                 AS posting_date
    , CAST(issuer_name AS string)                AS issuer_name
    , CAST(enterprise_type AS string)            AS enterprise_type
    , CAST(business_sector AS string)            AS business_sector
    , CAST(bond_code AS string)                  AS bond_code
    , CAST(currency AS string)                   AS currency
    , CAST(term_unit AS string)                  AS term_unit
    , CAST(term AS int)                          AS term
    , CAST(issue_date AS date)                   AS issue_date
    , CAST(maturity_date AS date)                AS maturity_date
    , CAST(remaining_term AS int)                AS remaining_term
    , CAST(offering_volume AS bigint)            AS offering_volume
    , CAST(par_value AS decimal(18,2))           AS par_value
    , CAST(interest_payment_type AS string)      AS interest_payment_type
    , CAST(interest_rate_type AS string)         AS interest_rate_type
    , CAST(interest_payment_method AS string)    AS interest_payment_method
    , CAST(repurchase_and_swap AS string)        AS repurchase_and_swap
    , CAST(issue_market AS string)               AS issue_market
    , CAST(issue_interest_rate AS decimal(10,2)) AS issue_interest_rate
    , CAST(convertible_bond AS string)           AS convertible_bond
    , CAST(warrant_linked_bond AS string)        AS warrant_linked_bond
    , CAST(secured_bond AS string)               AS secured_bond
    , CAST(business_no AS string)                AS business_no
    , CAST(report_day AS string)                 AS report_day
    , CAST(report_year AS string)                AS report_year
FROM {{ source('source_hnx', 'raw_private_corp_bond_offering') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
