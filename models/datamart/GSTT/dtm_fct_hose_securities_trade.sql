/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_hose_securities_trade
* Program name: Dtm Fct HOSE Securities Trade
* Created by: tuan.nguyenvanb
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_hose_securities_trade.csv]
*                                       Fact lenh khop HOSE - 1 dong / lenh khop (grain atomic
*                                       atm_securities_trade, loc src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE').
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
        , security_symbol_code
        , currency_code
        , board_tp_code
        , securities_trade_code
        , trade_time
        , session_code
        , execution_price
        , execution_price_versus_ltp
        , execution_vol
        , execution_val
        , execution_last_traded_price
        , execution_new_high_low_price_indicator
        , buy_order_dt
        , buy_order_time
        , buy_securities_order_code
        , buy_broker_id
        , buy_broker_nm
        , buy_account_pin_code
        , buy_account_nbr
        , buy_account_holder_nm
        , buy_client_house_cl_code
        , buy_investor_tp_code
        , buy_foreign_investor_tp_code
        , buy_order_price
        , buy_order_vol
        , buy_trader_nbr
        , buy_trader_nm
        , buy_reference_sequence_nbr
        , sell_order_dt
        , sell_order_time
        , sell_securities_order_code
        , sell_broker_id
        , sell_broker_nm
        , sell_account_pin_code
        , sell_account_nbr
        , sell_account_holder_nm
        , sell_client_house_cl_code
        , sell_investor_tp_code
        , sell_foreign_investor_tp_code
        , sell_order_price
        , sell_order_vol
        , sell_trader_nbr
        , sell_trader_nm
        , sell_reference_sequence_nbr
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE'
)

SELECT
    CAST(date_format(se_tr.trade_dt, 'yyyyMMdd') AS string)              AS trade_dt_dim_id,
    CAST(se_tr.market_id_code AS string)                                 AS market_id_code,
    CAST(se_tr.security_symbol_code AS string)                           AS security_symbol_code,
    CAST(se_tr.currency_code AS string)                                  AS currency_code,
    CAST(se_tr.board_tp_code AS string)                                  AS board_tp_code,
    CAST(se_tr.securities_trade_code AS string)                          AS securities_trade_code,
    CAST(se_tr.trade_time AS string)                                     AS trade_time,
    CAST(se_tr.session_code AS string)                                   AS session_code,
    CAST(se_tr.execution_price AS decimal(23,2))                         AS execution_price,
    CAST(se_tr.execution_price_versus_ltp AS decimal(23,2))              AS execution_price_versus_ltp,
    CAST(se_tr.execution_vol AS int)                                     AS execution_vol,
    CAST(se_tr.execution_val AS decimal(23,2))                           AS execution_val,
    CAST(se_tr.execution_last_traded_price AS decimal(23,2))             AS execution_last_traded_price,
    CAST(se_tr.execution_new_high_low_price_indicator AS string)         AS execution_new_high_low_price_indicator,
    CAST(se_tr.buy_order_dt AS date)                                     AS buy_order_dt,
    CAST(se_tr.buy_order_time AS string)                                 AS buy_order_time,
    CAST(se_tr.buy_securities_order_code AS string)                      AS buy_securities_order_code,
    CAST(se_tr.buy_broker_id AS string)                                  AS buy_broker_id,
    CAST(se_tr.buy_broker_nm AS string)                                  AS buy_broker_nm,
    CAST(se_tr.buy_account_pin_code AS string)                           AS buy_account_pin_code,
    CAST(se_tr.buy_account_nbr AS string)                                AS buy_account_nbr,
    CAST(se_tr.buy_account_holder_nm AS string)                          AS buy_account_holder_nm,
    CAST(se_tr.buy_client_house_cl_code AS string)                       AS buy_client_house_cl_code,
    CAST(se_tr.buy_investor_tp_code AS string)                           AS buy_investor_tp_code,
    CAST(se_tr.buy_foreign_investor_tp_code AS string)                   AS buy_foreign_investor_tp_code,
    CAST(se_tr.buy_order_price AS decimal(23,2))                         AS buy_order_price,
    CAST(se_tr.buy_order_vol AS int)                                     AS buy_order_vol,
    CAST(se_tr.buy_trader_nbr AS string)                                 AS buy_trader_nbr,
    CAST(se_tr.buy_trader_nm AS string)                                  AS buy_trader_nm,
    CAST(se_tr.buy_reference_sequence_nbr AS string)                     AS buy_reference_sequence_nbr,
    CAST(se_tr.sell_order_dt AS date)                                    AS sell_order_dt,
    CAST(se_tr.sell_order_time AS string)                                AS sell_order_time,
    CAST(se_tr.sell_securities_order_code AS string)                     AS sell_securities_order_code,
    CAST(se_tr.sell_broker_id AS string)                                 AS sell_broker_id,
    CAST(se_tr.sell_broker_nm AS string)                                 AS sell_broker_nm,
    CAST(se_tr.sell_account_pin_code AS string)                          AS sell_account_pin_code,
    CAST(se_tr.sell_account_nbr AS string)                               AS sell_account_nbr,
    CAST(se_tr.sell_account_holder_nm AS string)                         AS sell_account_holder_nm,
    CAST(se_tr.sell_client_house_cl_code AS string)                      AS sell_client_house_cl_code,
    CAST(se_tr.sell_investor_tp_code AS string)                          AS sell_investor_tp_code,
    CAST(se_tr.sell_foreign_investor_tp_code AS string)                  AS sell_foreign_investor_tp_code,
    CAST(se_tr.sell_order_price AS decimal(23,2))                        AS sell_order_price,
    CAST(se_tr.sell_order_vol AS int)                                    AS sell_order_vol,
    CAST(se_tr.sell_trader_nbr AS string)                                AS sell_trader_nbr,
    CAST(se_tr.sell_trader_nm AS string)                                 AS sell_trader_nm,
    CAST(se_tr.sell_reference_sequence_nbr AS string)                    AS sell_reference_sequence_nbr
FROM se_tr
