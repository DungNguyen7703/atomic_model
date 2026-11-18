-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_security_trading_daily_flat
-- Type  : FACT
-- 2026-09-30 tuan.nguyenvanb: [MOI, LLD DTM_GSTT_fct_security_trading_daily, O_GSTT_51]
-- Flat Fact Security Trading Daily (nen ngay) x Calendar Date x Security Trading Snapshot
-- Dimension - cung pattern voi gstt_fct_security_trading_intraday_flat.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Security Trading Daily
    f.security_trading_snpst_dim_id,
    f.trade_dt_dim_id,
    f.daily_open_price,
    f.daily_high_price,
    f.daily_low_price,
    f.daily_close_price,
    f.daily_vol,
    -- CALENDAR DATE
    to_date(f.trade_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date,
    -- SECURITY TRADING SNAPSHOT DIMENSION
    scr_dim.symbol                         AS symbol,
    scr_dim.security_full_nm               AS security_full_nm,
    scr_dim.floor_code                     AS floor_code,
    scr_dim.stock_tp_code                  AS stock_tp_code,
    scr_dim.stock_tp_nm                    AS stock_tp_nm,
    scr_dim.src_stm_code                   AS security_trading_src_stm_code

FROM {{ ref('dtm_fct_security_trading_daily') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr scr_dim
    ON scr_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND scr_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
