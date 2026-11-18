/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_hnx_securities_trade
* Program name: Dtm Fct HNX Securities Trade
* Created by: tuan.nguyenvanb
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_hnx_securities_trade.csv]
*                                       Fact lenh khop HNX - 1 dong / lenh khop (grain atomic
*                                       atm_securities_trade, loc src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX').
*                                       Toan bo cot direct tu atomic (khong lookup dim ngoai
*                                       cdr_dt_dim). trade_dt_dim_id format truc tiep tu
*                                       trade_dt (khong join dtm_cdr_dt_dim), dung quy uoc
*                                       chung GSTT. CANH BAO KHOI LUONG: bang rat lon, ClickHouse
*                                       flat nen luon loc theo cdr_dt + security_symbol_code
*                                       khi khai thac.
*--------------------------------------------------------------------*
*/

WITH se_tr AS (
    SELECT
        trade_dt
        , market_id_code
        , board_tp_code
        , security_symbol_code
        , securities_trade_code
        , trade_time
        , execution_price
        , execution_vol
        , session_code
        , sell_order_action_tp_code
        , sell_broker_id
        , sell_account_nbr
        , sell_order_tp_code
        , sell_order_condition_code
        , sell_client_house_cl_code
        , sell_investor_tp_code
        , sell_order_vol
        , sell_order_price
        , buy_broker_id
        , buy_order_action_tp_code
        , buy_account_nbr
        , buy_order_tp_code
        , buy_order_condition_code
        , buy_client_house_cl_code
        , buy_investor_tp_code
        , buy_order_vol
        , buy_order_price
        , message_sequence_nbr
        , sell_securities_order_code
        , buy_securities_order_code
        , sell_quote_request_tp_code
        , buy_quote_request_tp_code
        , execution_price_spread_first
        , execution_price_spread_second
        , sell_foreign_investor_tp_code
        , buy_foreign_investor_tp_code
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
)

SELECT
    CAST(date_format(se_tr.trade_dt, 'yyyyMMdd') AS string)              AS trade_dt_dim_id,
    CAST(se_tr.market_id_code AS string)                                 AS market_id_code,
    CAST(se_tr.board_tp_code AS string)                                  AS board_tp_code,
    CAST(se_tr.security_symbol_code AS string)                           AS security_symbol_code,
    CAST(se_tr.securities_trade_code AS string)                          AS securities_trade_code,
    CAST(se_tr.trade_time AS string)                                     AS trade_time,
    CAST(se_tr.execution_price AS decimal(23,2))                         AS execution_price,
    CAST(se_tr.execution_vol AS int)                                     AS execution_vol,
    CAST(se_tr.session_code AS string)                                   AS session_code,
    CAST(se_tr.sell_order_action_tp_code AS string)                      AS sell_order_action_tp_code,
    CAST(se_tr.sell_broker_id AS string)                                 AS sell_broker_id,
    CAST(se_tr.sell_account_nbr AS string)                               AS sell_account_nbr,
    CAST(se_tr.sell_order_tp_code AS string)                             AS sell_order_tp_code,
    CAST(se_tr.sell_order_condition_code AS string)                      AS sell_order_condition_code,
    CAST(se_tr.sell_client_house_cl_code AS string)                      AS sell_client_house_cl_code,
    CAST(se_tr.sell_investor_tp_code AS string)                          AS sell_investor_tp_code,
    CAST(se_tr.sell_order_vol AS int)                                    AS sell_order_vol,
    CAST(se_tr.sell_order_price AS decimal(23,2))                        AS sell_order_price,
    CAST(se_tr.buy_broker_id AS string)                                  AS buy_broker_id,
    CAST(se_tr.buy_order_action_tp_code AS string)                       AS buy_order_action_tp_code,
    CAST(se_tr.buy_account_nbr AS string)                                AS buy_account_nbr,
    CAST(se_tr.buy_order_tp_code AS string)                              AS buy_order_tp_code,
    CAST(se_tr.buy_order_condition_code AS string)                       AS buy_order_condition_code,
    CAST(se_tr.buy_client_house_cl_code AS string)                       AS buy_client_house_cl_code,
    CAST(se_tr.buy_investor_tp_code AS string)                           AS buy_investor_tp_code,
    CAST(se_tr.buy_order_vol AS int)                                     AS buy_order_vol,
    CAST(se_tr.buy_order_price AS decimal(23,2))                         AS buy_order_price,
    CAST(se_tr.message_sequence_nbr AS int)                              AS message_sequence_nbr,
    CAST(se_tr.sell_securities_order_code AS string)                     AS sell_securities_order_code,
    CAST(se_tr.buy_securities_order_code AS string)                      AS buy_securities_order_code,
    CAST(se_tr.sell_quote_request_tp_code AS string)                     AS sell_quote_request_tp_code,
    CAST(se_tr.buy_quote_request_tp_code AS string)                      AS buy_quote_request_tp_code,
    CAST(se_tr.execution_price_spread_first AS decimal(23,2))            AS execution_price_spread_first,
    CAST(se_tr.execution_price_spread_second AS decimal(23,2))           AS execution_price_spread_second,
    CAST(se_tr.sell_foreign_investor_tp_code AS string)                  AS sell_foreign_investor_tp_code,
    CAST(se_tr.buy_foreign_investor_tp_code AS string)                   AS buy_foreign_investor_tp_code
FROM se_tr
