-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_foreign_trading_min_snpst_flat
-- Type  : FACT
-- 2026-09-21 tuan.nguyenvanb: [MOI, theo LLD] Flat table cho Fact Foreign Trading Minute
-- Snapshot - GD NDTNN theo phut (O_GSTT_8). Grain rat min (per-minute) - luu y hieu nang
-- khi khai thac tren ClickHouse, nen luon loc theo symbol/khoang gio khi truy van.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Foreign Trading Minute Snapshot
    f.security_trading_snpst_dim_id,
    f.snpst_dt_dim_id,
    f.trade_minute_tms,
    f.foreign_buy_val_at_min,
    f.foreign_sell_val_at_min,
    -- CALENDAR DATE
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date,
    -- SECURITY TRADING SNAPSHOT DIMENSION
    sec_dim.symbol                         AS symbol,
    sec_dim.security_full_nm               AS security_full_nm,
    sec_dim.floor_code                     AS floor_code,
    sec_dim.stock_tp_code                  AS stock_tp_code,
    sec_dim.stock_tp_nm                    AS stock_tp_nm,
    sec_dim.src_stm_code                   AS security_trading_src_stm_code

FROM {{ ref('dtm_fct_foreign_trading_min_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr sec_dim
    ON sec_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND sec_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND sec_dim.ds_rcrd_st = 'ACTIVE'
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
