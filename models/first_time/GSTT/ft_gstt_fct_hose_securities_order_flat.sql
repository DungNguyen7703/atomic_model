-- [FIRST-TIME] ft_gstt_fct_hose_securities_order_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_fct_hose_securities_order_flat (config ft_target='gstt_fct_hose_securities_order_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_hose_securities_order_flat
-- Type  : FACT
-- 2026-10-01 tuan.nguyenvanb: [MOI, theo LLD] Flat table cho Fact HOSE Securities Order (lenh dat HOSE) x
-- Calendar Date. Grain 1 dong / lenh dat - khoi luong rat lon, khi khai thac tren
-- ClickHouse luon loc theo cdr_dt + security_symbol_code.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT HOSE Securities Order
    f.trade_dt_dim_id,
    f.market_id_code,
    f.security_symbol_code,
    f.currency_code,
    f.board_tp_code,
    f.order_dt,
    f.order_time,
    f.session_code,
    f.order_action_tp_code,
    f.order_accept_id,
    f.original_order_accept_id,
    f.side_ind,
    f.broker_id,
    f.broker_nm,
    f.account_pin_code,
    f.account_nbr,
    f.account_holder_nm,
    f.market_maker_order_ind,
    f.client_house_cl_code,
    f.investor_tp_code,
    f.foreign_investor_tp_code,
    f.order_tp_code,
    f.order_price,
    f.order_vol,
    f.order_condition_code,
    f.last_traded_price,
    f.execution_price,
    f.immediate_matched_vol,
    f.matched_vol,
    f.remaining_quantity,
    f.order_spread,
    f.matched_ratio,
    f.price_change_amt,
    f.price_change_tick,
    f.new_high_low_price_ind,
    f.order_status_code,
    f.icd_bug_quantity,
    f.expected_execution_price,
    f.expected_execution_vol,
    f.short_sell_tp_code,
    f.trader_nbr,
    f.trader_nm,
    f.reference_sequence_nbr,
    f.securities_order_code,
    f.original_order_code,
    -- CALENDAR DATE
    to_date(f.trade_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date

FROM {{ ft_ref('ft_dtm_fct_hose_securities_order') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
-- [BACKFILL-UAT-ORIG] WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI bo loc WHERE theo etl_date de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
