-- [FIRST-TIME] ft_atm_securities_trade_ordertrade_trade_book_hnx: ban ephemeral cua atm_securities_trade_ordertrade_trade_book_hnx cho bo first-time.
/*
*--------------------------------------------------------------------*
* Program code: atm_securities_trade
* Program name: Atomic Securities Trade ORDERTRADE.TRADE_BOOK_HNX
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
(ORDERTRADE.TRADE_BOOK_HNX.TRADE_TIME, varchar) CHUA co mau gia tri xac nhan dinh
dang cu the - GIA DINH tam 'HH:mm:ss'. Can Data Modeler/DBA profile lai du lieu that
truoc khi tin dung cho production; khong duoc coi day la final.
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH tr_bo_hn AS (
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
        , year
        , month
        , day
    FROM {{ ft_ref('ft_ods_hnx_trade_book') }}
     -- [BACKFILL-UAT-ORIG] WHERE TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
 -- [BACKFILL-UAT-ORIG] or TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyyMMdd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyyMMdd')
)

SELECT
    {{ generate_surrogate_key_bigint('ORDERTRADE_TRADE_BOOK_HNX', "tr_bo_hn.trade_number") }}                  AS securities_trade_id
    , CAST(tr_bo_hn.trade_number AS string)                                                                    AS securities_trade_code
    , CAST('ORDERTRADE_TRADE_BOOK_HNX' AS string)                                                              AS src_stm_code
    , CAST(to_date(tr_bo_hn.trade_date, 'yyyy-MM-dd') AS date)                                                                        AS trade_dt
    , CAST(tr_bo_hn.market_id AS string)                                                                       AS market_id_code
    , CAST(tr_bo_hn.issue_code AS string)                                                                      AS security_symbol_code
    , CAST(null AS string)                                                                                     AS currency_code
    , CAST(tr_bo_hn.board_id AS string)                                                                        AS board_tp_code
    , CAST(tr_bo_hn.trade_time AS string)                                                                      AS trade_time
    , CAST(to_timestamp(concat(cast(tr_bo_hn.trade_date AS string), ' ', tr_bo_hn.trade_time)) AS timestamp)   AS trade_tms
    , CAST(tr_bo_hn.session_id AS string)                                                                      AS session_code
    , CAST(tr_bo_hn.message_sequence AS int)                                                                   AS message_sequence_nbr
    , CAST(tr_bo_hn.trade_price AS decimal(23,2))                                                              AS execution_price
    , CAST(null AS decimal(23,2))                                                                              AS execution_price_versus_ltp
    , CAST(tr_bo_hn.trade_quantity AS int)                                                                     AS execution_vol
    , CAST((tr_bo_hn.trade_price * tr_bo_hn.trade_quantity) AS DECIMAL(23,2))                                  AS execution_val
    , CAST(null AS decimal(23,2))                                                                              AS execution_last_traded_price
    , CAST(null AS string)                                                                                     AS execution_new_high_low_price_indicator
    , CAST(tr_bo_hn.execution_price_of_spread_first AS decimal(23,2))                                          AS execution_price_spread_first
    , CAST(tr_bo_hn.execution_price_of_spread_second AS decimal(23,2))                                         AS execution_price_spread_second
    , CAST(null AS date)                                                                                       AS buy_order_dt
    , CAST(null AS string)                                                                                     AS buy_order_time
    , CAST(tr_bo_hn.buy_replace_cancel_classification_code AS string)                                          AS buy_order_action_tp_code
    , {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HNX', "tr_bo_hn.buy_order_reception_number") }}  AS buy_securities_order_id
    , CAST(tr_bo_hn.buy_order_reception_number AS string)                                                      AS buy_securities_order_code
    , CAST(tr_bo_hn.buy_member_number AS string)                                                               AS buy_broker_id
    , CAST(null AS string)                                                                                     AS buy_broker_nm
    , CAST(null AS string)                                                                                     AS buy_account_pin_code
    , CAST(tr_bo_hn.buy_account_number AS string)                                                              AS buy_account_nbr
    , CAST(NULL AS string)                                                                                     AS buy_account_holder_nm
    , CAST(tr_bo_hn.buy_order_type_code AS string)                                                             AS buy_order_tp_code
    , CAST(tr_bo_hn.buy_order_condition_code AS string)                                                        AS buy_order_condition_code
    , CAST(tr_bo_hn.buy_client_house_classification AS string)                                                 AS buy_client_house_cl_code
    , CAST(tr_bo_hn.buy_investor_classification_code AS string)                                                AS buy_investor_tp_code
    , CAST(tr_bo_hn.buy_foreign_investor_type_code AS string)                                                  AS buy_foreign_investor_tp_code
    , CAST(tr_bo_hn.buy_quote_request_code AS string)                                                          AS buy_quote_request_tp_code
    , CAST(tr_bo_hn.buy_order_price AS decimal(23,2))                                                          AS buy_order_price
    , CAST(tr_bo_hn.buy_order_quantity AS int)                                                                 AS buy_order_vol
    , CAST(null AS string)                                                                                     AS buy_trader_nbr
    , CAST(null AS string)                                                                                     AS buy_trader_nm
    , CAST(null AS string)                                                                                     AS buy_reference_sequence_nbr
    , CAST(null AS date)                                                                                       AS sell_order_dt
    , CAST(null AS string)                                                                                     AS sell_order_time
    , CAST(tr_bo_hn.sell_replace_cancel_classification_code AS string)                                         AS sell_order_action_tp_code
    , {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HNX', "tr_bo_hn.sell_order_reception_number") }} AS sell_securities_order_id
    , CAST(tr_bo_hn.sell_order_reception_number AS string)                                                     AS sell_securities_order_code
    , CAST(tr_bo_hn.sell_member_number AS string)                                                              AS sell_broker_id
    , CAST(null AS string)                                                                                     AS sell_broker_nm
    , CAST(null AS string)                                                                                     AS sell_account_pin_code
    , CAST(tr_bo_hn.sell_account_number AS string)                                                             AS sell_account_nbr
    , CAST(null AS string)                                                                                     AS sell_account_holder_nm
    , CAST(tr_bo_hn.sell_order_type_code AS string)                                                            AS sell_order_tp_code
    , CAST(tr_bo_hn.sell_order_condition_code AS string)                                                       AS sell_order_condition_code
    , CAST(tr_bo_hn.sell_client_house_classification AS string)                                                AS sell_client_house_cl_code
    , CAST(tr_bo_hn.sell_investor_classification_code AS string)                                               AS sell_investor_tp_code
    , CAST(tr_bo_hn.sell_foreign_investor_type_code AS string)                                                 AS sell_foreign_investor_tp_code
    , CAST(tr_bo_hn.sell_quote_request_code AS string)                                                         AS sell_quote_request_tp_code
    , CAST(tr_bo_hn.sell_order_price AS decimal(23,2))                                                         AS sell_order_price
    , CAST(tr_bo_hn.sell_order_quantity AS int)                                                                AS sell_order_vol
    , CAST(null AS string)                                                                                     AS sell_trader_nbr
    , CAST(null AS string)                                                                                     AS sell_trader_nm
    , CAST(null AS string)                                                                                     AS sell_reference_sequence_nbr
    , CAST(tr_bo_hn.year AS string)                                                                             AS year
    , CAST(tr_bo_hn.month AS string)                                                                            AS month
    , CAST(tr_bo_hn.day AS string)                                                                              AS day
FROM tr_bo_hn