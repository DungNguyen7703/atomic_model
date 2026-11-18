-- [FIRST-TIME] ft_ods_hnx_order_book: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_hnx_order_book (config ft_target='order_book', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_order_book
* Program name: ODS HNX.ORDER_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-11		tuan.nguyenvanb		Chuyen tu models/ods/ordertrade/ods_ordertrade_order_book_hnx.sql
*                                       - domain "ordertrade" khong con dung, tach rieng theo
*                                       dung nguon that (HNX/HOSE).
*--------------------------------------------------------------------*
*/

SELECT
    CASE
        WHEN length(trade_date) = 8 THEN to_date(trade_date, 'yyyyMMdd')
        ELSE to_date(trade_date, 'yyyy-MM-dd')
    END                                            AS trade_date
    , CAST(market_id AS string)                    AS market_id
    , CAST(board_id AS string)                      AS board_id
    , CAST(issue_code AS string)                    AS issue_code
    , CAST(order_accept_time AS string)             AS order_accept_time
    , CAST(member_id AS string)                     AS member_id
    , CAST(sell_buy_classification_code AS string)  AS sell_buy_classification_code
    , CAST(account_number AS string)                AS account_number
    , CAST(order_type_code AS string)               AS order_type_code
    , CAST(order_condition_code AS string)          AS order_condition_code
    , CAST(client_house_classification_code AS string) AS client_house_classification_code
    , CAST(investor_classification_code AS string)  AS investor_classification_code
    , CASE
        WHEN length(order_date) = 8 THEN to_date(order_date, 'yyyyMMdd')
        ELSE to_date(order_date, 'yyyy-MM-dd')
    END                                            AS order_date
    , CAST(order_reject_reason_code AS string)      AS order_reject_reason_code
    , CAST(order_quantity AS int)                   AS order_quantity
    , CAST(order_price AS decimal(23,2))            AS order_price
    , CAST(public_quantity AS int)                  AS public_quantity
    , CAST(condition_price AS decimal(23,2))        AS condition_price
    , CAST(order_reception_number AS string)        AS order_reception_number
    , CAST(original_order_reception_number AS string) AS original_order_reception_number
    , CAST(original_order_type_code AS string)      AS original_order_type_code
    , CAST(session_id AS string)                    AS session_id
    , CAST(order_remaining_quantity AS int)         AS order_remaining_quantity
    , CAST(message_sequence AS int)                 AS message_sequence
    , CAST(replace_cancel AS string)                AS replace_cancel
    , CAST(quote_request_type AS string)            AS quote_request_type
    , CAST(automated_cancel AS string)              AS automated_cancel
    , CAST(order_id AS string)                      AS order_id
    , CAST(original_order_id AS string)             AS original_order_id
    , CAST(foreign_investor_type_code AS string)    AS foreign_investor_type_code
    , CAST(year AS string)                          AS year
    , CAST(month AS string)                         AS month
    , CAST(day AS string)                           AS day
FROM {{ source('source_hnx', 'raw_order_book_hnx') }}
--WHERE TRADE_DATE = REGEXP_REPLACE('{{ var("etl_date") }}', '-','')
