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

-- 2026-11-14: HOSE doi ten cot khop HNX -> map giong HNX; cot rieng cua HOSE khong con nguon -> NULL.
WITH tr_bo_ho AS (
    SELECT
        trade_number
        , trade_date
        , market_id
        , board_id
        , issue_code
        , trade_time
        , trade_price
        , trade_quantity
        , session_id
        , message_sequence
        , sell_replace_cancel_classification_code
        , sell_member_number
        , sell_account_number
        , sell_order_type_code
        , sell_order_condition_code
        , sell_client_house_classification
        , sell_investor_classification_code
        , sell_order_quantity
        , sell_order_price
        , sell_order_reception_number
        , sell_foreign_investor_type_code
        , sell_quote_request_code
        , buy_replace_cancel_classification_code
        , buy_member_number
        , buy_account_number
        , buy_order_type_code
        , buy_order_condition_code
        , buy_client_house_classification
        , buy_investor_classification_code
        , buy_order_quantity
        , buy_order_price
        , buy_order_reception_number
        , buy_foreign_investor_type_code
        , buy_quote_request_code
        , execution_price_of_spread_first
        , execution_price_of_spread_second
        , report_year
        , report_month
        , report_day
    FROM {{ ref('ods_hose_trade_book') }}
    WHERE trade_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HOSE_TRADE_BOOK', "trade_number") }} AS securities_trade_id
    , CAST(trade_number AS string) AS securities_trade_code
    , CAST('HOSE_TRADE_BOOK' AS string) AS src_stm_code
    , CAST(to_date(trade_date, 'yyyy-MM-dd') AS date) AS trade_dt
    , CAST(market_id AS string) AS market_code
    , CAST(issue_code AS string) AS ticker_symbol
    , CAST(board_id AS string) AS board_tp_code
    , CAST(session_id AS string) AS session_code
    , CAST(trade_time AS string) AS trade_time
    , CAST(trade_price AS decimal(23,2)) AS match_price
    , CAST(trade_quantity AS bigint) AS match_quantity
    , CAST(message_sequence AS string) AS message_sequence_nbr
    , CAST(execution_price_of_spread_first AS decimal(23,2)) AS match_price_spread_first
    , CAST(execution_price_of_spread_second AS decimal(23,2)) AS match_price_spread_second
    , CAST(buy_order_reception_number AS bigint) AS buy_order_reception_code
    , CAST(buy_member_number AS string) AS buy_member_code
    , CAST(buy_account_number AS string) AS buy_account_nbr
    , CAST(buy_client_house_classification AS string) AS buy_account_tp_code
    , CAST(buy_investor_classification_code AS string) AS buy_investor_tp_code
    , CAST(buy_foreign_investor_type_code AS string) AS buy_foreign_investor_tp_code
    , CAST(buy_order_price AS decimal(23,2)) AS buy_order_price
    , CAST(buy_order_quantity AS bigint) AS buy_order_quantity
    , CAST(buy_replace_cancel_classification_code AS string) AS buy_order_action_tp_code
    , CAST(buy_order_type_code AS string) AS buy_order_tp_code
    , CAST(buy_order_condition_code AS string) AS buy_order_condition_tp_code
    , CAST(buy_quote_request_code AS string) AS buy_quote_request_tp_code
    , CAST(sell_order_reception_number AS bigint) AS sell_order_reception_code
    , CAST(sell_member_number AS string) AS sell_member_code
    , CAST(sell_account_number AS string) AS sell_account_nbr
    , CAST(sell_client_house_classification AS string) AS sell_account_tp_code
    , CAST(sell_investor_classification_code AS string) AS sell_investor_tp_code
    , CAST(sell_foreign_investor_type_code AS string) AS sell_foreign_investor_tp_code
    , CAST(sell_order_price AS decimal(23,2)) AS sell_order_price
    , CAST(sell_order_quantity AS bigint) AS sell_order_quantity
    , CAST(sell_replace_cancel_classification_code AS string) AS sell_order_action_tp_code
    , CAST(sell_order_type_code AS string) AS sell_order_tp_code
    , CAST(sell_order_condition_code AS string) AS sell_order_condition_tp_code
    , CAST(sell_quote_request_code AS string) AS sell_quote_request_tp_code
    , CAST(report_year AS int) AS rpt_year
    , CAST(report_month AS int) AS rpt_month
    , CAST(report_day AS int) AS rpt_day
FROM tr_bo_ho