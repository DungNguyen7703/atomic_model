-- [FIRST-TIME] ft_atm_securities_trade_ordertrade_trade_book_hose: ban ephemeral cua atm_securities_trade_ordertrade_trade_book_hose cho bo first-time.
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

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
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
    FROM {{ ft_ref('ft_ods_hose_trade_book') }}
     -- [BACKFILL-UAT-ORIG] WHERE TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
     -- [BACKFILL-UAT-ORIG] or TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyyMMdd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyyMMdd')
)

SELECT
    {{ generate_surrogate_key_bigint('ORDERTRADE_TRADE_BOOK_HOSE', "tr_bo_ho.trade_no") }}               AS securities_trade_id
    , CAST(tr_bo_ho.trade_no AS string)                                                                  AS securities_trade_code
    , CAST('ORDERTRADE_TRADE_BOOK_HOSE' AS string)                                                       AS src_stm_code
    , CAST(to_date(tr_bo_ho.trade_date, 'yyyy-MM-dd') AS date)                                                                  AS trade_dt
    , CAST(tr_bo_ho.market_id AS string)                                                                 AS market_id_code
    , CAST(tr_bo_ho.symbol AS string)                                                                    AS security_symbol_code
    , CAST(tr_bo_ho.currency AS string)                                                                  AS currency_code
    , CAST(tr_bo_ho.board_type AS string)                                                                AS board_tp_code
    , CAST(tr_bo_ho.time AS string)                                                                      AS trade_time
    , CAST(to_timestamp(concat(cast(tr_bo_ho.trade_date AS string), ' ', tr_bo_ho.time)) AS timestamp)   AS trade_tms
    , CAST(tr_bo_ho.session AS string)                                                                   AS session_code
    , CAST(null AS int)                                                                                  AS message_sequence_nbr
    , CAST(tr_bo_ho.execution_exec_price AS decimal(23,2))                                               AS execution_price
    , CAST(tr_bo_ho.execution_exec_price_ltp AS decimal(23,2))                                           AS execution_price_versus_ltp
    , CAST(tr_bo_ho.execution_volume AS int)                                                             AS execution_vol
    , CAST(tr_bo_ho.execution_value AS decimal(23,2))                                                    AS execution_val
    , CAST(tr_bo_ho.execution_ltp AS decimal(23,2))                                                      AS execution_last_traded_price
    , CAST(tr_bo_ho.execution_new_high_low_price AS string)                                              AS execution_new_high_low_price_indicator
    , CAST(null AS decimal(23,2))                                                                        AS execution_price_spread_first
    , CAST(null AS decimal(23,2))                                                                        AS execution_price_spread_second
    , CAST(tr_bo_ho.buy_order_date AS date)                                                              AS buy_order_dt
    , CAST(tr_bo_ho.buy_order_time AS string)                                                            AS buy_order_time
    , CAST(null AS string)                                                                               AS buy_order_action_tp_code
    , {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HOSE', "tr_bo_ho.buy_order_accept_no") }}  AS buy_securities_order_id
    , CAST(tr_bo_ho.buy_order_accept_no AS string)                                                       AS buy_securities_order_code
    , CAST(tr_bo_ho.buy_brk_no AS string)                                                                AS buy_broker_id
    , CAST(tr_bo_ho.buy_brk AS string)                                                                   AS buy_broker_nm
    , CAST(tr_bo_ho.buy_pin AS string)                                                                   AS buy_account_pin_code
    , CAST(tr_bo_ho.buy_acct_no AS string)                                                               AS buy_account_nbr
    , CAST(tr_bo_ho.buy_name AS string)                                                                  AS buy_account_holder_nm
    , CAST(null AS string)                                                                               AS buy_order_tp_code
    , CAST(null AS string)                                                                               AS buy_order_condition_code
    , CAST(tr_bo_ho.buy_client_house_classification_code AS string)                                      AS buy_client_house_cl_code
    , CAST(tr_bo_ho.buy_invest_type AS string)                                                           AS buy_investor_tp_code
    , CAST(tr_bo_ho.buy_foreigner_investor_type AS string)                                               AS buy_foreign_investor_tp_code
    , CAST(null AS string)                                                                               AS buy_quote_request_tp_code
    , CAST(tr_bo_ho.buy_order_price AS decimal(23,2))                                                    AS buy_order_price
    , CAST(tr_bo_ho.buy_order_vol AS int)                                                                AS buy_order_vol
    , CAST(tr_bo_ho.buy_trader_no AS string)                                                             AS buy_trader_nbr
    , CAST(tr_bo_ho.buy_trader_name AS string)                                                           AS buy_trader_nm
    , CAST(tr_bo_ho.buy_reference_sequence_no AS string)                                                 AS buy_reference_sequence_nbr
    , CAST(tr_bo_ho.sell_order_date AS date)                                                             AS sell_order_dt
    , CAST(tr_bo_ho.sell_order_time AS string)                                                           AS sell_order_time
    , CAST(null AS string)                                                                               AS sell_order_action_tp_code
    , {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HOSE', "tr_bo_ho.sell_order_accept_no") }} AS sell_securities_order_id
    , CAST(tr_bo_ho.sell_order_accept_no AS string)                                                      AS sell_securities_order_code
    , CAST(tr_bo_ho.sell_brk_no AS string)                                                               AS sell_broker_id
    , CAST(tr_bo_ho.sell_brk AS string)                                                                  AS sell_broker_nm
    , CAST(tr_bo_ho.sell_pin AS string)                                                                  AS sell_account_pin_code
    , CAST(tr_bo_ho.sell_acct_no AS string)                                                              AS sell_account_nbr
    , CAST(tr_bo_ho.sell_name AS string)                                                                 AS sell_account_holder_nm
    , CAST(null AS string)                                                                               AS sell_order_tp_code
    , CAST(null AS string)                                                                               AS sell_order_condition_code
    , CAST(tr_bo_ho.sell_client_house_classification_code AS string)                                     AS sell_client_house_cl_code
    , CAST(tr_bo_ho.sell_invest_type AS string)                                                          AS sell_investor_tp_code
    , CAST(tr_bo_ho.sell_foreigner_investor_type AS string)                                              AS sell_foreign_investor_tp_code
    , CAST(null AS string)                                                                               AS sell_quote_request_tp_code
    , CAST(tr_bo_ho.sell_order_price AS decimal(23,2))                                                   AS sell_order_price
    , CAST(tr_bo_ho.sell_order_vol AS int)                                                               AS sell_order_vol
    , CAST(tr_bo_ho.sell_trader_no AS string)                                                            AS sell_trader_nbr
    , CAST(tr_bo_ho.sell_trader_name AS string)                                                          AS sell_trader_nm
    , CAST(tr_bo_ho.sell_reference_sequence_no AS string)                                                AS sell_reference_sequence_nbr
    , CAST(tr_bo_ho.year AS string)                                                                      AS year
    , CAST(tr_bo_ho.month AS string)                                                                     AS month
    , CAST(tr_bo_ho.day AS string)                                                                       AS day
FROM tr_bo_ho