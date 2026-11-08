/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_gov_bond_listed_list
* Program name: ODS HNX.GOV_BOND_LISTED_LIST
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(bond_code AS string)                  AS bond_code
    , CAST(issuer_name AS string)               AS issuer_name
    , CAST(bond_type AS string)                 AS bond_type
    , CAST(listed_volume AS bigint)             AS listed_volume
    , CAST(bond_term AS string)                 AS bond_term
    , CAST(remaining_term AS string)            AS remaining_term
    , CAST(interest_payment_method AS string)   AS interest_payment_method
    , CAST(interest_payment_type AS string)     AS interest_payment_type
    , CAST(interest_rate AS decimal(10,2))      AS interest_rate
    , CAST(first_trading_date AS date)          AS first_trading_date
    , CAST(status AS string)                    AS status
    , CAST(report_month AS string)               AS report_month
    , CAST(ds_snpst_dt AS date)                  AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_gov_bond_listed_list') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
