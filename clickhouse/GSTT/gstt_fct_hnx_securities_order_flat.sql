-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_hnx_securities_order_flat
-- Type  : FACT
-- 2026-10-01 tuan.nguyenvanb: [MOI, theo LLD] Flat table cho Fact HNX Securities Order (lenh dat HNX) x
-- Calendar Date. Grain 1 dong / lenh dat - khoi luong rat lon, khi khai thac tren
-- ClickHouse luon loc theo cdr_dt + security_symbol_code.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT HNX Securities Order
    f.trade_dt_dim_id,
    f.market_id_code,
    f.board_tp_code,
    f.security_symbol_code,
    f.order_accept_time,
    f.broker_id,
    f.side_ind,
    f.account_nbr,
    f.order_tp_code,
    f.order_condition_code,
    f.client_house_cl_code,
    f.investor_tp_code,
    f.order_dt,
    f.order_reject_reason_code,
    f.order_vol,
    f.order_price,
    f.public_vol,
    f.condition_price,
    f.order_reception_nbr,
    f.original_order_reception_nbr,
    f.original_order_tp_code,
    f.session_code,
    f.remaining_quantity,
    f.message_sequence_nbr,
    f.order_action_tp_code,
    f.quote_request_tp_code,
    f.auto_cancel_reason_code,
    f.securities_order_code,
    f.original_order_code,
    f.foreign_investor_tp_code,
    -- CALENDAR DATE
    to_date(f.trade_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date

FROM {{ ref('dtm_fct_hnx_securities_order') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
