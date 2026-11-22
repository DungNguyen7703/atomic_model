/*
*--------------------------------------------------------------------*
* Program code: atm_pc_stock_listing_history
* Program name: Atomic Pc Stock Listing History
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
        , action_type_cd
        , sequence_no
        , exchange_cd
        , equity_ticker
        , decision_no
        , decision_date
        , trading_date
        , delisting_date
        , listed_share_qty
        , change_share_qty
        , total_share_qty_after_change
    FROM {{ ref('ods_ids_stock_listing_history') }}
    WHERE created_date >= TO_TIMESTAMP('{{ var("etl_date") }}')
        AND created_date < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_STOCK_LISTING_HISTORY', "id") }}              AS pc_stock_listing_history_id
    , CAST(id AS string)                                                                AS pc_stock_listing_history_code
    , CAST('IDS_STOCK_LISTING_HISTORY' AS string)                                       AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(action_type_cd AS string)                                                    AS stock_listing_action_tp_code
    , CAST(sequence_no AS int)                                                          AS sequence_nbr
    , CAST(exchange_cd AS string)                                                       AS exchange_code
    , CAST(equity_ticker AS string)                                                     AS equity_ticker_symbol
    , CAST(decision_no AS string)                                                       AS decision_nbr
    , CAST(decision_date AS date)                                                       AS decision_dt
    , CAST(trading_date AS date)                                                        AS trading_dt
    , CAST(delisting_date AS date)                                                      AS delisting_dt
    , CAST(listed_share_qty AS bigint)                                                  AS listed_share_quantity
    , CAST(change_share_qty AS bigint)                                                  AS change_share_quantity
    , CAST(total_share_qty_after_change AS bigint)                                      AS total_share_quantity_after_change
FROM src
