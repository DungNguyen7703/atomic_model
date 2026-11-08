/*
*--------------------------------------------------------------------*
* Program code: atm_securities_trade
* Program name: Atomic Securities Trade ORDERTRADE.TRADE_BOOK_HOSE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-04		tuan.nguyenvanb		Bo sung cot trade_tms theo LLD DTM_GSTT_fct_
*                                       foreign_trading_min_snpst
*--------------------------------------------------------------------*
*/

/*
!!! CANH BAO - COT trade_tms MOI BO SUNG, NGUON TIME CHUA XAC NHAN DINH DANG !!!
LLD (O_GSTT_8) yeu cau trade_tms noi tu Trade Date + Trade Time, giong ky thuat da
dung cho trading_tms cua security_trading_snapshot. Cot TIME goc
(ORDERTRADE.TRADE_BOOK_HOSE.TIME, varchar(20)) CHUA co mau gia tri xac nhan dinh
dang cu the - GIA DINH tam 'HH:mm:ss'. Can Data Modeler/DBA profile lai du lieu that
truoc khi tin dung cho production; khong duoc coi day la final.
*/

WITH tr_bo_ho AS (
    SELECT
        trade_no
        , trade_date
        , market_id
        , symbol
        , currency
        , board_type
        , time
        , session
        , execution_exec_price
        , execution_exec_price_ltp
        , execution_volume
        , execution_value
        , execution_ltp
        , execution_new_high_low_price
        , buy_order_date
        , buy_order_time
        , buy_order_accept_no
        , buy_brk_no
        , buy_brk
        , buy_pin
        , buy_acct_no
        , buy_name
        , buy_client_house_classification_code
        , buy_invest_type
        , buy_foreigner_investor_type
        , buy_order_price
        , buy_order_vol
        , buy_trader_no
        , buy_trader_name
        , buy_reference_sequence_no
        , sell_order_date
        , sell_order_time
        , sell_order_accept_no
        , sell_brk_no
        , sell_brk
        , sell_pin
        , sell_acct_no
        , sell_name
        , sell_client_house_classification_code
        , sell_invest_type
        , sell_foreigner_investor_type
        , sell_order_price
        , sell_order_vol
        , sell_trader_no
        , sell_trader_name
        , sell_reference_sequence_no
        , year
        , month
        , day
    FROM {{ ref('ods_hose_trade_book') }}
    WHERE trade_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('ORDERTRADE_TRADE_BOOK_HOSE', "trade_no") }}               AS securities_trade_id
    , CAST(trade_no AS string)                                                                  AS securities_trade_code
    , CAST('ORDERTRADE_TRADE_BOOK_HOSE' AS string)                                                       AS src_stm_code
    , CAST(to_date(trade_date, 'yyyy-MM-dd') AS date)                                                                  AS trade_dt
    , CAST(market_id AS string)                                                                 AS market_id_code
    , CAST(symbol AS string)                                                                    AS security_symbol_code
    , CAST(currency AS string)                                                                  AS currency_code
    , CAST(board_type AS string)                                                                AS board_tp_code
    , CAST(time AS string)                                                                      AS trade_time
    , CAST(to_timestamp(concat(cast(trade_date AS string), ' ', time)) AS timestamp)   AS trade_tms
    , CAST(session AS string)                                                                   AS session_code
    , CAST(null AS int)                                                                                  AS message_sequence_nbr
    , CAST(execution_exec_price AS decimal(23,2))                                               AS execution_price
    , CAST(execution_exec_price_ltp AS decimal(23,2))                                           AS execution_price_versus_ltp
    , CAST(execution_volume AS int)                                                             AS execution_vol
    , CAST(execution_value AS decimal(23,2))                                                    AS execution_val
    , CAST(execution_ltp AS decimal(23,2))                                                      AS execution_last_traded_price
    , CAST(execution_new_high_low_price AS string)                                              AS execution_new_high_low_price_indicator
    , CAST(null AS decimal(23,2))                                                                        AS execution_price_spread_first
    , CAST(null AS decimal(23,2))                                                                        AS execution_price_spread_second
    , CAST(buy_order_date AS date)                                                              AS buy_order_dt
    , CAST(buy_order_time AS string)                                                            AS buy_order_time
    , CAST(null AS string)                                                                               AS buy_order_action_tp_code
    , {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HOSE', "buy_order_accept_no") }}  AS buy_securities_order_id
    , CAST(buy_order_accept_no AS string)                                                       AS buy_securities_order_code
    , CAST(buy_brk_no AS string)                                                                AS buy_broker_id
    , CAST(buy_brk AS string)                                                                   AS buy_broker_nm
    , CAST(buy_pin AS string)                                                                   AS buy_account_pin_code
    , CAST(buy_acct_no AS string)                                                               AS buy_account_nbr
    , CAST(buy_name AS string)                                                                  AS buy_account_holder_nm
    , CAST(null AS string)                                                                               AS buy_order_tp_code
    , CAST(null AS string)                                                                               AS buy_order_condition_code
    , CAST(buy_client_house_classification_code AS string)                                      AS buy_client_house_cl_code
    , CAST(buy_invest_type AS string)                                                           AS buy_investor_tp_code
    , CAST(buy_foreigner_investor_type AS string)                                               AS buy_foreign_investor_tp_code
    , CAST(null AS string)                                                                               AS buy_quote_request_tp_code
    , CAST(buy_order_price AS decimal(23,2))                                                    AS buy_order_price
    , CAST(buy_order_vol AS int)                                                                AS buy_order_vol
    , CAST(buy_trader_no AS string)                                                             AS buy_trader_nbr
    , CAST(buy_trader_name AS string)                                                           AS buy_trader_nm
    , CAST(buy_reference_sequence_no AS string)                                                 AS buy_reference_sequence_nbr
    , CAST(sell_order_date AS date)                                                             AS sell_order_dt
    , CAST(sell_order_time AS string)                                                           AS sell_order_time
    , CAST(null AS string)                                                                               AS sell_order_action_tp_code
    , {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HOSE', "sell_order_accept_no") }} AS sell_securities_order_id
    , CAST(sell_order_accept_no AS string)                                                      AS sell_securities_order_code
    , CAST(sell_brk_no AS string)                                                               AS sell_broker_id
    , CAST(sell_brk AS string)                                                                  AS sell_broker_nm
    , CAST(sell_pin AS string)                                                                  AS sell_account_pin_code
    , CAST(sell_acct_no AS string)                                                              AS sell_account_nbr
    , CAST(sell_name AS string)                                                                 AS sell_account_holder_nm
    , CAST(null AS string)                                                                               AS sell_order_tp_code
    , CAST(null AS string)                                                                               AS sell_order_condition_code
    , CAST(sell_client_house_classification_code AS string)                                     AS sell_client_house_cl_code
    , CAST(sell_invest_type AS string)                                                          AS sell_investor_tp_code
    , CAST(sell_foreigner_investor_type AS string)                                              AS sell_foreign_investor_tp_code
    , CAST(null AS string)                                                                               AS sell_quote_request_tp_code
    , CAST(sell_order_price AS decimal(23,2))                                                   AS sell_order_price
    , CAST(sell_order_vol AS int)                                                               AS sell_order_vol
    , CAST(sell_trader_no AS string)                                                            AS sell_trader_nbr
    , CAST(sell_trader_name AS string)                                                          AS sell_trader_nm
    , CAST(sell_reference_sequence_no AS string)                                                AS sell_reference_sequence_nbr
    , CAST(year AS string)                                                                      AS year
    , CAST(month AS string)                                                                     AS month
    , CAST(day AS string)                                                                       AS day
FROM tr_bo_ho