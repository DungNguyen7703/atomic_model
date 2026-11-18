/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_gov_bond_offering
* Program name: ODS HNX.GOV_BOND_OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(bidding_method AS string)             AS bidding_method
    , CAST(bidding_session AS string)          AS bidding_session
    , CAST(bond_code AS string)                AS bond_code
    , CAST(issuer_name AS string)              AS issuer_name
    , CAST(bond_type AS string)                AS bond_type
    , CAST(term AS string)                     AS term
    , CAST(issue_date AS date)                 AS issue_date
    , CAST(issue_method AS string)             AS issue_method
    , CAST(calling_value AS decimal(18,2))     AS calling_value
    , CAST(bidding_value AS decimal(18,2))     AS bidding_value
    , CAST(winning_value AS decimal(18,2))     AS winning_value
    , CAST(nominal_interest_rate AS decimal(10,2)) AS nominal_interest_rate
    , CAST(winning_interest_rate AS decimal(10,2)) AS winning_interest_rate
    , CAST(report_month AS string)             AS report_month
    , CAST(ds_snpst_dt AS date)                AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_gov_bond_offering') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
