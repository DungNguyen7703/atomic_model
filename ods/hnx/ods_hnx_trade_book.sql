/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_trade_book
* Program name: ODS HNX.TRADE_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-11		tuan.nguyenvanb		Chuyen tu models/ods/ordertrade/ods_ordertrade_trade_book_hnx.sql
*                                       - domain "ordertrade" khong con dung, tach rieng theo
*                                       dung nguon that (HNX/HOSE).
*--------------------------------------------------------------------*
*/

SELECT
    CASE
        WHEN length(trade_date) = 8 THEN to_date(trade_date, 'yyyyMMdd')
        ELSE to_date(trade_date, 'yyyy-MM-dd')
    END                                              AS trade_date
    , CAST(market_id AS string)                      AS market_id
    , CAST(board_id AS string)                       AS board_id
    , CAST(issue_code AS string)                     AS issue_code
    , CAST(trade_number AS string)                    AS trade_number
    , CAST(trade_time AS string)                      AS trade_time
    , CAST(trade_price AS decimal(23,2))              AS trade_price
    , CAST(trade_quantity AS int)                     AS trade_quantity
    , CAST(session_id AS string)                      AS session_id
    , CAST(sell_replace_cancel_classification_code AS string) AS sell_replace_cancel_classification_code
    , CAST(sell_member_number AS string)               AS sell_member_number
    , CAST(sell_account_number AS string)              AS sell_account_number
    , CAST(sell_order_type_code AS string)             AS sell_order_type_code
    , CAST(sell_order_condition_code AS string)        AS sell_order_condition_code
    , CAST(sell_client_house_classification AS string) AS sell_client_house_classification
    , CAST(sell_investor_classification_code AS string) AS sell_investor_classification_code
    , CAST(sell_order_quantity AS int)                 AS sell_order_quantity
    , CAST(sell_order_price AS decimal(23,2))          AS sell_order_price
    , CAST(buy_member_number AS string)                AS buy_member_number
    , CAST(buy_replace_cancel_classification_code AS string) AS buy_replace_cancel_classification_code
    , CAST(buy_account_number AS string)               AS buy_account_number
    , CAST(buy_order_type_code AS string)              AS buy_order_type_code
    , CAST(buy_order_condition_code AS string)         AS buy_order_condition_code
    , CAST(buy_client_house_classification AS string)  AS buy_client_house_classification
    , CAST(buy_investor_classification_code AS string) AS buy_investor_classification_code
    , CAST(buy_order_quantity AS int)                  AS buy_order_quantity
    , CAST(buy_order_price AS decimal(23,2))           AS buy_order_price
    , CAST(message_sequence AS int)                    AS message_sequence
    , CAST(sell_order_reception_number AS string)      AS sell_order_reception_number
    , CAST(buy_order_reception_number AS string)       AS buy_order_reception_number
    , CAST(sell_quote_request_code AS string)          AS sell_quote_request_code
    , CAST(buy_quote_request_code AS string)           AS buy_quote_request_code
    , CAST(execution_price_of_spread_first AS decimal(23,2))  AS execution_price_of_spread_first
    , CAST(execution_price_of_spread_second AS decimal(23,2)) AS execution_price_of_spread_second
    , CAST(sell_foreign_investor_type_code AS string)  AS sell_foreign_investor_type_code
    , CAST(buy_foreign_investor_type_code AS string)   AS buy_foreign_investor_type_code
    , CAST(year AS string)                             AS year
    , CAST(month AS string)                            AS month
    , CAST(day AS string)                              AS day
FROM {{ source('source_hnx', 'raw_trade_book_hnx') }}
WHERE to_date(trade_date, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
