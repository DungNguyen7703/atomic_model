/*
*--------------------------------------------------------------------*
* Program code: atm_securities_order
* Program name: Atomic Securities Order ORDERTRADE.ORDER_BOOK_HOSE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Schema chuan hoa theo LLD_ORDERTRADE_ORDER_BOOK_HNX.yaml + LLD_ORDERTRADE_ORDER_BOOK_HOSE.yaml
* (2 nguon HNX/HOSE union vao chung 1 Atomic Entity "Securities Order" - phai cung
* 1 bo cot/thu tu/kieu du lieu de UNION ALL voi atm_securities_order_ordertrade_order_book_hnx).
* Field nao HOSE khong co (theo LLD) -> NULL.
*--------------------------------------------------------------------*
*/

WITH or_bo_ho AS (
    SELECT
        order_id
        , trade_date
        , market_id
        , symbol
        , currency
        , board_type
        , order_date
        , order_time
        , session
        , modify_cancel
        , order_accept_id
        , orig_order_accept_id
        , orig_order_id
        , side
        , brk_id
        , brk
        , pin
        , acct_no
        , name
        , market_maker_order
        , client_house_classification_code
        , invest_type
        , foreigner_investor_type
        , order_type
        , order_price
        , order_vol
        , order_condition
        , ltp
        , execution_price
        , immed_matched_vol
        , matched_vol
        , order_rqty
        , order_price_ltp
        , matched_ratio
        , buy_up_sell_down_amt
        , buy_up_sell_down_tick
        , new_high_low_price
        , order_status
        , icd_bug_qty
        , expected_execution_price
        , expected_execution_volume
        , short_sell_indicator
        , trader_no
        , trader_name
        , reference_sequence_no
    FROM {{ ref('ods_hose_order_book') }}
    WHERE trade_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HOSE', "order_id") }} AS securities_order_id
    , CAST(order_id AS string)                                                    AS securities_order_code
    , CAST('ORDERTRADE_ORDER_BOOK_HOSE' AS string)                                AS src_stm_code
    , CAST(trade_date AS date)                                                    AS trade_dt
    , CAST(market_id AS string)                                                   AS market_id_code
    , CAST(board_type AS string)                                                  AS board_tp_code
    , CAST(symbol AS string)                                                      AS security_symbol_code
    , CAST(brk_id AS string)                                                      AS broker_id
    , CAST(side AS string)                                                        AS side_ind
    , CAST(acct_no AS string)                                                     AS account_nbr
    , CAST(order_type AS string)                                                  AS order_tp_code
    , CAST(order_condition AS string)                                             AS order_condition_code
    , CAST(client_house_classification_code AS string)                            AS client_house_cl_code
    , CAST(invest_type AS string)                                                 AS investor_tp_code
    , CAST(order_date AS date)                                                    AS order_dt
    , CAST(order_vol AS int)                                                      AS order_vol
    , CAST(order_price AS decimal(23,2))                                          AS order_price
    , CAST(session AS string)                                                     AS session_code
    , CAST(order_rqty AS int)                                                     AS remaining_quantity
    , CAST(modify_cancel AS string)                                               AS order_action_tp_code
    , CAST(orig_order_id AS string)                                               AS original_order_code
    , CAST(foreigner_investor_type AS string)                                     AS foreign_investor_tp_code
    , CAST(order_status AS string)                                                AS order_status_code
    -- HNX-only (khong co ben HOSE theo LLD) - NULL het
    , CAST(null AS string)                                                        AS order_accept_time
    , CAST(null AS string)                                                        AS order_reject_reason_code
    , CAST(null AS int)                                                           AS public_vol
    , CAST(null AS decimal(23,2))                                                 AS condition_price
    , CAST(null AS string)                                                        AS order_reception_nbr
    , CAST(null AS string)                                                        AS original_order_reception_nbr
    , CAST(null AS string)                                                        AS original_order_tp_code
    , CAST(null AS int)                                                           AS message_sequence_nbr
    , CAST(null AS string)                                                        AS quote_request_tp_code
    , CAST(null AS string)                                                        AS auto_cancel_reason_code
    -- HOSE-only (khong co ben HNX theo LLD)
    , CAST(currency AS string)                                                    AS currency_code
    , CAST(order_time AS string)                                                  AS order_time
    , CAST(order_accept_id AS string)                                             AS order_accept_id
    , CAST(orig_order_accept_id AS string)                                        AS original_order_accept_id
    , CAST(brk AS string)                                                         AS broker_nm
    , CAST(pin AS string)                                                         AS account_pin_code
    , CAST(name AS string)                                                        AS account_holder_nm
    , CAST(market_maker_order AS string)                                          AS market_maker_order_ind
    , CAST(ltp AS decimal(23,2))                                                  AS last_traded_price
    , CAST(execution_price AS decimal(23,2))                                      AS execution_price
    , CAST(immed_matched_vol AS int)                                              AS immediate_matched_vol
    , CAST(matched_vol AS int)                                                    AS matched_vol
    , CAST(order_price_ltp AS decimal(23,2))                                      AS order_spread
    , CAST(matched_ratio AS decimal(5,2))                                         AS matched_ratio
    , CAST(buy_up_sell_down_amt AS decimal(23,2))                                 AS price_change_amt
    , CAST(buy_up_sell_down_tick AS int)                                          AS price_change_tick
    , CAST(new_high_low_price AS string)                                          AS new_high_low_price_ind
    , CAST(icd_bug_qty AS int)                                                    AS icd_bug_quantity
    , CAST(expected_execution_price AS decimal(23,2))                             AS expected_execution_price
    , CAST(expected_execution_volume AS int)                                      AS expected_execution_vol
    , CAST(short_sell_indicator AS string)                                        AS short_sell_tp_code
    , CAST(trader_no AS string)                                                   AS trader_nbr
    , CAST(trader_name AS string)                                                 AS trader_nm
    , CAST(reference_sequence_no AS string)                                       AS reference_sequence_nbr
FROM or_bo_ho
