-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_instrument_price_intraday_flat
-- Type  : FACT
-- 2026-10-06 tuan.nguyenvanb: [MOI, LLD DTM_GSTT_fct_instrument_price_intraday, GSTT Nhom 34, v4.33-v4.36]
-- Flat Fact Instrument Price Intraday (nen PHUT ma CK VA chi so) x Calendar Date x Security Trading
-- Snapshot Dimension (LEFT JOIN - NULL voi dong chi so). THAY gstt_fct_security_trading_intraday_flat
-- (LLD bai bo; model cu giu nguyen trong repo, chua xoa).
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Instrument Price Intraday
    f.security_trading_snpst_dim_id,
    f.trade_dt_dim_id,
    f.instrument_code,
    f.trading_tms,
    f.open_price,
    f.high_price,
    f.low_price,
    f.close_price,
    f.vol,
    f.cumulative_vol_at_time,
    -- CALENDAR DATE
    to_date(f.trade_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date,
    -- SECURITY TRADING SNAPSHOT DIMENSION (NULL voi dong chi so)
    scr_dim.symbol                         AS symbol,
    scr_dim.security_full_nm               AS security_full_nm,
    scr_dim.floor_code                     AS floor_code,
    scr_dim.stock_tp_code                  AS stock_tp_code,
    scr_dim.stock_tp_nm                    AS stock_tp_nm,
    scr_dim.src_stm_code                   AS security_trading_src_stm_code

FROM {{ ref('dtm_fct_instrument_price_intraday') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr scr_dim
    ON scr_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND scr_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
