-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_hnx_securities_trade_flat
-- Type  : FACT
-- 2026-10-01 tuan.nguyenvanb: [MOI, theo LLD] Flat table cho Fact HNX Securities Trade (lenh khop HNX) x
-- Calendar Date. Grain 1 dong / lenh khop - khoi luong rat lon, khi khai thac tren
-- ClickHouse luon loc theo cdr_dt + security_symbol_code.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT HNX Securities Trade
    f.trade_dt_dim_id,
    f.market_id_code,
    f.board_tp_code,
    f.security_symbol_code,
    f.securities_trade_code,
    f.trade_time,
    f.execution_price,
    f.execution_vol,
    f.session_code,
    f.sell_order_action_tp_code,
    f.sell_broker_id,
    f.sell_account_nbr,
    f.sell_order_tp_code,
    f.sell_order_condition_code,
    f.sell_client_house_cl_code,
    f.sell_investor_tp_code,
    f.sell_order_vol,
    f.sell_order_price,
    f.buy_broker_id,
    f.buy_order_action_tp_code,
    f.buy_account_nbr,
    f.buy_order_tp_code,
    f.buy_order_condition_code,
    f.buy_client_house_cl_code,
    f.buy_investor_tp_code,
    f.buy_order_vol,
    f.buy_order_price,
    f.message_sequence_nbr,
    f.sell_securities_order_code,
    f.buy_securities_order_code,
    f.sell_quote_request_tp_code,
    f.buy_quote_request_tp_code,
    f.execution_price_spread_first,
    f.execution_price_spread_second,
    f.sell_foreign_investor_tp_code,
    f.buy_foreign_investor_tp_code,
    -- CALENDAR DATE
    to_date(f.trade_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date

FROM {{ ref('dtm_fct_hnx_securities_trade') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
