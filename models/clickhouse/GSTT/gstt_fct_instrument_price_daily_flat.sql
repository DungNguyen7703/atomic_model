-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_instrument_price_daily_flat
-- Type  : FACT
-- 2026-10-06 tuan.nguyenvanb: [MOI, LLD DTM_GSTT_fct_instrument_price_daily, GSTT Nhom 34, v4.33-v4.36]
-- Flat Fact Instrument Price Daily (nen NGAY ma CK VA chi so + Doanh thu/LNST) x Calendar Date x
-- Security Trading Snapshot Dimension (LEFT JOIN - NULL voi dong chi so). Cung pattern voi
-- gstt_fct_security_trading_daily_flat.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Instrument Price Daily
    f.security_trading_snpst_dim_id,
    f.trade_dt_dim_id,
    f.instrument_code,
    f.open_price,
    f.high_price,
    f.low_price,
    f.close_price,
    f.vol,
    f.revenue,
    f.net_profit_after_tax,
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

FROM {{ ref('dtm_fct_instrument_price_daily') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr scr_dim
    ON scr_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND scr_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
