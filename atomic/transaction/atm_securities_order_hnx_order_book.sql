/*
*--------------------------------------------------------------------*
* Program code: atm_securities_order
* Program name: Atomic Securities Order ORDERTRADE.ORDER_BOOK_HNX
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Schema chuan hoa theo LLD_HNX_ORDER_BOOK.yaml + LLD_ORDERTRADE_ORDER_BOOK_HOSE.yaml
* (2 nguon HNX/HOSE union vao chung 1 Atomic Entity "Securities Order" - phai cung
* 1 bo cot/thu tu/kieu du lieu de UNION ALL voi atm_securities_order_ordertrade_order_book_hose).
* Field nao HNX khong co (theo LLD) -> NULL.
*--------------------------------------------------------------------*
*/

WITH or_bo_hn AS (
    SELECT
        order_id
        , trade_date
        , market_id
        , board_id
        , issue_code
        , member_id
        , sell_buy_classification_code
        , account_number
        , order_type_code
        , order_condition_code
        , client_house_classification_code
        , investor_classification_code
        , order_date
        , order_quantity
        , order_price
        , session_id
        , order_remaining_quantity
        , replace_cancel
        , original_order_id
        , foreign_investor_type_code
        , order_accept_time
        , order_reject_reason_code
        , public_quantity
        , condition_price
        , order_reception_number
        , original_order_reception_number
        , original_order_type_code
        , message_sequence
        , quote_request_type
        , automated_cancel
        , report_year
        , report_month
        , report_day
    FROM {{ ref('ods_hnx_order_book') }}
    WHERE trade_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_ORDER_BOOK', "order_id") }} AS securities_order_id
    , CAST(order_id AS string) AS securities_order_code
    , CAST('HNX_ORDER_BOOK' AS string) AS src_stm_code
    , CAST(trade_date AS date) AS trade_dt
    , CAST(market_id AS string) AS market_code
    , CAST(issue_code AS string) AS ticker_symbol
    , CAST(board_id AS string) AS board_tp_code
    , CAST(session_id AS string) AS session_code
    , CAST(sell_buy_classification_code AS string) AS side
    , CAST(replace_cancel AS string) AS order_action_tp_code
    , CAST(member_id AS string) AS member_code
    , CAST(account_number AS string) AS account_nbr
    , CAST(client_house_classification_code AS string) AS account_tp_code
    , CAST(investor_classification_code AS string) AS investor_tp_code
    , CAST(foreign_investor_type_code AS string) AS foreign_investor_tp_code
    , CAST(order_type_code AS string) AS order_tp_code
    , CAST(order_condition_code AS string) AS order_condition_tp_code
    , CAST(order_price AS decimal(23,2)) AS order_price
    , CAST(order_quantity AS bigint) AS order_quantity
    , CAST(order_remaining_quantity AS bigint) AS order_remaining_quantity
    , CAST(order_date AS date) AS order_dt
    , CAST(order_accept_time AS string) AS order_time
    , CAST(order_reception_number AS string) AS order_reception_code
    , CAST(original_order_reception_number AS string) AS original_order_reception_code
    , CAST(original_order_id AS string) AS original_order_code
    , CAST(message_sequence AS string) AS sequence_nbr
    , CAST(order_reject_reason_code AS string) AS order_reject_reason_code
    , CAST(public_quantity AS bigint) AS public_quantity
    , CAST(condition_price AS decimal(23,2)) AS condition_price
    , CAST(original_order_type_code AS string) AS original_order_tp_code
    , CAST(automated_cancel AS string) AS automated_cancel_tp_code
    , CAST(quote_request_type AS string) AS quote_request_tp_code
    , CAST(report_year AS int) AS rpt_year
    , CAST(report_month AS int) AS rpt_month
    , CAST(report_day AS int) AS rpt_day
FROM or_bo_hn
