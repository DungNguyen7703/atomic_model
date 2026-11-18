-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_hose_securities_trade_flat
-- Type  : FACT
-- 2026-10-01 tuan.nguyenvanb: [MOI, theo LLD] Flat table cho Fact HOSE Securities Trade (lenh khop HOSE) x
-- Calendar Date. Grain 1 dong / lenh khop - khoi luong rat lon, khi khai thac tren
-- ClickHouse luon loc theo cdr_dt + security_symbol_code.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT HOSE Securities Trade
    f.trade_dt_dim_id,
    f.market_id_code,
    f.security_symbol_code,
    f.currency_code,
    f.board_tp_code,
    f.securities_trade_code,
    f.trade_time,
    f.session_code,
    f.execution_price,
    f.execution_price_versus_ltp,
    f.execution_vol,
    f.execution_val,
    f.execution_last_traded_price,
    f.execution_new_high_low_price_indicator,
    f.buy_order_dt,
    f.buy_order_time,
    f.buy_securities_order_code,
    f.buy_broker_id,
    f.buy_broker_nm,
    f.buy_account_pin_code,
    f.buy_account_nbr,
    f.buy_account_holder_nm,
    f.buy_client_house_cl_code,
    f.buy_investor_tp_code,
    f.buy_foreign_investor_tp_code,
    f.buy_order_price,
    f.buy_order_vol,
    f.buy_trader_nbr,
    f.buy_trader_nm,
    f.buy_reference_sequence_nbr,
    f.sell_order_dt,
    f.sell_order_time,
    f.sell_securities_order_code,
    f.sell_broker_id,
    f.sell_broker_nm,
    f.sell_account_pin_code,
    f.sell_account_nbr,
    f.sell_account_holder_nm,
    f.sell_client_house_cl_code,
    f.sell_investor_tp_code,
    f.sell_foreign_investor_tp_code,
    f.sell_order_price,
    f.sell_order_vol,
    f.sell_trader_nbr,
    f.sell_trader_nm,
    f.sell_reference_sequence_nbr,
    -- CALENDAR DATE
    to_date(f.trade_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date

FROM {{ ref('dtm_fct_hose_securities_trade') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
