-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_market_index_intraday_flat
-- Type  : FACT
-- 2026-09-14 tuan.nguyenvanb: [BO SUNG theo pull LLD moi] Them cot is_trading_date -
-- JOIN dtm_cdr_dt_dim (dim da rebuild khong partition + BROADCAST, xem ghi chu chi tiet
-- o gstt_fct_stock_portfolio_snpst_flat.sql). cdr_dt van suy truc tiep tu trade_dt_dim_id (2026-10-13: doi ten theo LLD)
-- nhu cu, khong doi.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Market Index Intraday
    f.market_index_dim_id,
    f.trade_dt_dim_id,
    f.index_time,
    f.market_index_val_at_time,
    f.total_val_at_time,
    -- CALENDAR DATE
    to_date(f.trade_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                 AS is_trading_date,
    -- MARKET INDEX DIMENSION
    idx_dim.market_id                   AS market_id,
    idx_dim.market_code                 AS market_code,
    idx_dim.index_nm                    AS index_nm,
    idx_dim.index_tp_code               AS index_tp_code,
    idx_dim.tsc_product_group_id        AS tsc_product_group_id,
    idx_dim.market_status_code          AS market_status_code,
    idx_dim.src_stm_code                AS market_index_src_stm_code

FROM {{ ref('dtm_fct_market_index_intraday') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
-- [2026-10-20] Doc dim _hstr DUNG ngay snapshot (khong doc MAIN): chi so doi ten/ngung/INACTIVE o MAIN van ra dung ten theo ngay.
LEFT JOIN {{ ref('dtm_market_index_dim') }}_hstr idx_dim
    ON idx_dim.market_index_dim_id = f.market_index_dim_id
    AND idx_dim.ds_snpst_dt = to_date(f.trade_dt_dim_id, 'yyyyMMdd')
    AND idx_dim.ds_rcrd_st = 'ACTIVE'
WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')