/*
*--------------------------------------------------------------------*
* Program code: ods_hose_trade_book
* Program name: ODS HOSE.TRADE_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-11		tuan.nguyenvanb		Chuyen tu models/ods/ordertrade/ods_ordertrade_trade_book_hose.sql
*                                       - domain "ordertrade" khong con dung, tach rieng theo
*                                       dung nguon that (HNX/HOSE).
*--------------------------------------------------------------------*
*/

SELECT
    CASE
        WHEN length(trade_date) = 8 THEN to_date(trade_date, 'yyyyMMdd')
        ELSE to_date(trade_date, 'yyyy-MM-dd')
    END                                             AS trade_date
    , CAST(market_id AS string)                     AS market_id
    , CAST(symbol AS string)                        AS symbol
    , CAST(currency AS string)                      AS currency
    , CAST(board_type AS string)                    AS board_type
    , CAST(trade_no AS string)                      AS trade_no
    , CAST(time AS string)                          AS time
    , CAST(session AS string)                       AS session
    , CAST(execution_exec_price AS decimal(23,2))   AS execution_exec_price
    , CAST(execution_exec_price_ltp AS decimal(23,2)) AS execution_exec_price_ltp
    , CAST(execution_volume AS int)                 AS execution_volume
    , CAST(execution_value AS decimal(23,2))        AS execution_value
    , CAST(execution_ltp AS decimal(23,2))          AS execution_ltp
    , CAST(execution_new_high_low_price AS string)  AS execution_new_high_low_price
    , CASE
        WHEN length(buy_order_date) = 8 THEN to_date(buy_order_date, 'yyyyMMdd')
        ELSE to_date(buy_order_date, 'yyyy-MM-dd')
    END                                             AS buy_order_date
    , CAST(buy_order_time AS string)                AS buy_order_time
    , CAST(buy_order_accept_no AS string)             AS buy_order_accept_no
    , CAST(buy_brk_no AS string)                     AS buy_brk_no
    , CAST(buy_brk AS string)                       AS buy_brk
    , CAST(buy_pin AS string)                       AS buy_pin
    , CAST(buy_acct_no AS string)                   AS buy_acct_no
    , CAST(buy_name AS string)                      AS buy_name
    , CAST(buy_client_house_classification_code AS string) AS buy_client_house_classification_code
    , CAST(buy_invest_type AS string)               AS buy_invest_type
    , CAST(buy_foreigner_investor_type AS string)   AS buy_foreigner_investor_type
    , CAST(buy_order_price AS decimal(23,2))        AS buy_order_price
    , CAST(buy_order_vol AS int)                    AS buy_order_vol
    , CAST(buy_trader_no AS string)                 AS buy_trader_no
    , CAST(buy_trader_name AS string)               AS buy_trader_name
    , CAST(buy_reference_sequence_no AS string)     AS buy_reference_sequence_no
    , CASE
        WHEN length(sell_order_date) = 8 THEN to_date(sell_order_date, 'yyyyMMdd')
        ELSE to_date(sell_order_date, 'yyyy-MM-dd')
    END                                             AS sell_order_date
    , CAST(sell_order_time AS string)               AS sell_order_time
    , CAST(sell_order_accept_no AS string)           AS sell_order_accept_no
    , CAST(sell_brk_no AS string)                    AS sell_brk_no
    , CAST(sell_brk AS string)                      AS sell_brk
    , CAST(sell_pin AS string)                      AS sell_pin
    , CAST(sell_acct_no AS string)                  AS sell_acct_no
    , CAST(sell_name AS string)                     AS sell_name
    , CAST(sell_client_house_classification_code AS string) AS sell_client_house_classification_code
    , CAST(sell_invest_type AS string)               AS sell_invest_type
    , CAST(sell_foreigner_investor_type AS string)   AS sell_foreigner_investor_type
    , CAST(sell_order_price AS decimal(23,2))        AS sell_order_price
    , CAST(sell_order_vol AS int)                    AS sell_order_vol
    , CAST(sell_trader_no AS string)                 AS sell_trader_no
    , CAST(sell_trader_name AS string)               AS sell_trader_name
    , CAST(sell_reference_sequence_no AS string)     AS sell_reference_sequence_no
    , CAST(year AS string)                           AS year
    , CAST(month AS string)                          AS month
    , CAST(day AS string)                            AS day
FROM {{ source('source_hose', 'raw_trade_book_hose') }}
WHERE trade_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
