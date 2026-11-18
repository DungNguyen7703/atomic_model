-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_security_trading_intraday_flat
-- Type  : FACT
-- 2026-09-14 tuan.nguyenvanb: [BO SUNG theo pull LLD moi] Them cot is_trading_date -
-- JOIN dtm_cdr_dt_dim (dim da rebuild khong partition + BROADCAST, xem ghi chu chi tiet
-- o gstt_fct_stock_portfolio_snpst_flat.sql). cdr_dt van suy truc tiep tu cdr_dt_dim_id
-- nhu cu, khong doi.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Security Trading Intraday
    f.security_trading_snpst_dim_id,
    f.cdr_dt_dim_id,
    f.trading_tms,
    f.open_price_at_time,
    f.high_price_at_time,
    f.low_price_at_time,
    f.close_price_at_time,
    f.cumulative_vol_at_time,
    -- CALENDAR DATE
    to_date(f.cdr_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                 AS is_trading_date,
    -- SECURITY TRADING SNAPSHOT DIMENSION
    scr_dim.symbol                      AS symbol,
    scr_dim.security_full_nm            AS security_full_nm,
    scr_dim.floor_code                  AS floor_code,
    scr_dim.stock_tp_code               AS stock_tp_code,
    scr_dim.stock_tp_nm                 AS stock_tp_nm,
    scr_dim.src_stm_code                AS security_trading_src_stm_code

FROM {{ ref('dtm_fct_security_trading_intraday') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr scr_dim
    ON scr_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND scr_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.cdr_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')