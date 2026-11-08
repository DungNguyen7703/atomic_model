-- [FIRST-TIME] ft_ods_hose_order_book: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_hose_order_book (config ft_target='order_book', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_hose_order_book
* Program name: ODS HOSE.ORDER_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-11		tuan.nguyenvanb		Chuyen tu models/ods/ordertrade/ods_ordertrade_order_book_hose.sql
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
    , CASE
        WHEN length(order_date) = 8 THEN to_date(order_date, 'yyyyMMdd')
        ELSE to_date(order_date, 'yyyy-MM-dd')
    END                                             AS order_date
    , CAST(order_time AS string)                    AS order_time
    , CAST(session AS string)                       AS session
    , CAST(modify_cancel AS string)                 AS modify_cancel
    , CAST(order_accept_id AS string)                AS order_accept_id
    , CAST(orig_order_accept_id AS string)           AS orig_order_accept_id
    , CAST(side AS string)                          AS side
    , CAST(brk_id AS string)                        AS brk_id
    , CAST(brk AS string)                           AS brk
    , CAST(pin AS string)                           AS pin
    , CAST(acct_no AS string)                       AS acct_no
    , CAST(name AS string)                          AS name
    , CAST(market_maker_order AS string)            AS market_maker_order
    , CAST(client_house_classification_code AS string) AS client_house_classification_code
    , CAST(invest_type AS string)                   AS invest_type
    , CAST(foreigner_investor_type AS string)       AS foreigner_investor_type
    , CAST(order_type AS string)                    AS order_type
    , CAST(order_price AS decimal(23,2))            AS order_price
    , CAST(order_vol AS int)                        AS order_vol
    , CAST(order_condition AS string)               AS order_condition
    , CAST(ltp AS decimal(23,2))                    AS ltp
    , CAST(execution_price AS decimal(23,2))        AS execution_price
    , CAST(immed_matched_vol AS int)                AS immed_matched_vol
    , CAST(matched_vol AS int)                      AS matched_vol
    , CAST(order_rqty AS int)                       AS order_rqty
    , CAST(order_price_ltp AS decimal(23,2))        AS order_price_ltp
    , CAST(matched_ratio AS decimal(5,2))           AS matched_ratio
    , CAST(buy_up_sell_down_amt AS decimal(23,2))   AS buy_up_sell_down_amt
    , CAST(buy_up_sell_down_tick AS int)             AS buy_up_sell_down_tick
    , CAST(new_high_low_price AS string)            AS new_high_low_price
    , CAST(order_status AS string)                  AS order_status
    , CAST(icd_bug_qty AS int)                      AS icd_bug_qty
    , CAST(expected_execution_price AS decimal(23,2)) AS expected_execution_price
    , CAST(expected_execution_volume AS int)        AS expected_execution_volume
    , CAST(short_sell_indicator AS string)          AS short_sell_indicator
    , CAST(trader_no AS string)                     AS trader_no
    , CAST(trader_name AS string)                   AS trader_name
    , CAST(reference_sequence_no AS string)         AS reference_sequence_no
    , CAST(order_id AS string)                      AS order_id
    , CAST(orig_order_id AS string)                 AS orig_order_id
    , CAST(year AS string)                          AS year
    , CAST(month AS string)                         AS month
    , CAST(day AS string)                           AS day
FROM {{ source('source_hose', 'raw_order_book_hose') }}
-- [FIRST-TIME] bo loc ngay de nap toan bo lich su:
-- WHERE TRADE_DATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
