-- [FIRST-TIME] ft_gstt_fct_market_index_intraday_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_fct_market_index_intraday_flat (config ft_target='gstt_fct_market_index_intraday_flat', macro macros/first_time).
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

FROM {{ ft_ref('ft_dtm_fct_market_index_intraday') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.trade_dt_dim_id
-- [FIRST-TIME 2026-10-17] dim ft_hstr_by_day: doc _hstr theo dung ngay giao dich
LEFT JOIN {{ ft_ref('ft_dtm_market_index_dim') }}_hstr idx_dim
    ON idx_dim.market_index_dim_id = f.market_index_dim_id
    AND idx_dim.ds_snpst_dt = to_date(f.trade_dt_dim_id, 'yyyyMMdd')
    AND idx_dim.ds_rcrd_st = 'ACTIVE'
-- [BACKFILL-UAT-ORIG] WHERE f.trade_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI bo loc WHERE theo etl_date de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]