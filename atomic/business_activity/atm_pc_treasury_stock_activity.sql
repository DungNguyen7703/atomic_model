/*
*--------------------------------------------------------------------*
* Program code: atm_pc_treasury_stock_activity
* Program name: Atomic Pc Treasury Stock Activity
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_profile_id
        , transaction_year
        , treasury_buy_qty
        , treasury_buy_rc
        , treasury_sell_qty
        , treasury_sell_rc
    FROM {{ ref('ods_ids_company_treasury_stocks') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_TREASURY_STOCKS', "id") }}            AS pc_treasury_stock_activity_id
    , CAST(id AS string)                                                                AS pc_treasury_stock_activity_code
    , CAST('IDS_COMPANY_TREASURY_STOCKS' AS string)                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(transaction_year AS string)                                                  AS transaction_year
    , CAST(treasury_buy_qty AS bigint)                                                  AS treasury_buy_quantity
    , CAST(treasury_buy_rc AS int)                                                      AS treasury_buy_round_count
    , CAST(treasury_sell_qty AS bigint)                                                 AS treasury_sell_quantity
    , CAST(treasury_sell_rc AS int)                                                     AS treasury_sell_round_count
FROM src
