/*
*--------------------------------------------------------------------*
* Program code: atm_gov_bond_listing
* Program name: Atomic Gov Bond Listing
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH go_li AS (
    SELECT
        bond_code
        , issuer_name
        , bond_type
        , listed_volume
        , bond_term
        , remaining_term
        , interest_payment_method
        , interest_payment_type
        , interest_rate
        , first_trading_date
        , status
        , report_month
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_gov_bond_listed_list') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_GOV_BOND_LISTED_LIST', "go_li.bond_code") }} AS gov_bond_listing_id
    , CAST(go_li.bond_code AS string)                   AS bond_code
    , CAST('HNX_GOV_BOND_LISTED_LIST' AS string)        AS src_stm_code
    , CAST(go_li.issuer_name AS string)                 AS issuer_name
    , CAST(go_li.bond_type AS string)                   AS bond_tp
    , CAST(go_li.listed_volume AS bigint)               AS listed_bond_quantity
    , CAST(go_li.bond_term AS string)                   AS bond_term
    , CAST(go_li.remaining_term AS string)              AS remaining_bond_term
    , CAST(go_li.interest_payment_method AS string)     AS interest_payment_method
    , CAST(go_li.interest_payment_type AS string)       AS interest_payment_tp
    , CAST(go_li.interest_rate AS decimal(5,2))         AS interest_rate
    , CAST(go_li.first_trading_date AS date)            AS first_trading_date
    , CAST(go_li.status AS string)                      AS listing_status
    , CAST(go_li.report_month AS string)                AS report_month
FROM go_li
