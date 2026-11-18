-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_index_constituent_snpst_flat
-- Type  : FACT (Bridge factless)
-- 2026-09-14 tuan.nguyenvanb: [MOI, theo HLD v4.13] Tach khoi
-- gstt_fct_stock_portfolio_snpst_flat de het fan-out theo ro chi so - 1 dong / ma CK /
-- ro chi so / ngay giao dich. 8 measure idx_* la gia tri tinh san theo Index+Date, LAP LAI
-- tren moi dong Symbol cung index_code+cdr_dt (denormalize co chu dich) - khi truy van
-- TUYET DOI KHONG SUM lai, dung MAX()/ANY_VALUE()/SELECT DISTINCT theo (index_code, cdr_dt).
-- 2026-09-14 tuan.nguyenvanb: [BO SUNG theo pull LLD moi] Them cot is_trading_date -
-- JOIN dtm_cdr_dt_dim (dim da rebuild khong partition + BROADCAST, xem ghi chu chi tiet
-- o gstt_fct_stock_portfolio_snpst_flat.sql).
-- 2026-09-19 tuan.nguyenvanb: [LLD de8cd57c] Them idx_pe/idx_pb/idx_eps (K_GSTT_149/150/151)
-- va idx_prior_market_cap/idx_prior_free_float_market_cap (O_GSTT_25) - cung nhom idx_*
-- tinh san theo Index+Date, GIA TRI LAP LAI tren moi dong Symbol, KHONG duoc SUM/AVG lai
-- theo Symbol khi truy van.
-- 2026-09-25 tuan.nguyenvanb: [Doi chieu lai LLD] Them idx_market_index_val (LLD dong #11,
-- bi thieu khi build ban dau) - cung nhom idx_* tinh san theo Index+Date.
-- 2026-10-15 tuan.nguyenvanb: [LLD v4.49] Them idx_foreign_buy_vol/idx_foreign_sell_vol/idx_foreign_buy_val/
-- idx_foreign_sell_val (K_GSTT_370-373) - cung nhom idx_* tinh san theo Index+Date, GIA TRI LAP LAI tren moi dong
-- Symbol, KHONG duoc SUM/AVG lai theo Symbol khi truy van.
-- ────────────────────────────────────────────────────────────

SELECT /*+ REPARTITION(120), BROADCAST(cal) */
    -- FACT Index Constituent Snapshot
    f.security_trading_snpst_dim_id,
    f.index_constituent_dim_id,
    f.snpst_dt_dim_id,
    f.idx_total_matched_vol,
    f.idx_total_matched_val,
    f.idx_foreign_net_vol,
    f.idx_foreign_net_val,
    f.idx_total_negotiated_vol,
    f.idx_total_negotiated_val,
    f.idx_market_index_val,
    f.idx_market_cap,
    f.idx_free_float_market_cap,
    f.idx_pe,
    f.idx_pb,
    f.idx_eps,
    f.idx_prior_market_cap,
    f.idx_prior_free_float_market_cap,
    f.idx_foreign_buy_vol,
    f.idx_foreign_sell_vol,
    f.idx_foreign_buy_val,
    f.idx_foreign_sell_val,
    -- CALENDAR DATE
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')         AS cdr_dt,
    cal.is_trading_date                            AS is_trading_date,
    -- SECURITY TRADING SNAPSHOT DIMENSION
    sec_dim.symbol                                 AS symbol,
    -- INDEX CONSTITUENT DIMENSION
    idx_cons_dim.index_code                        AS index_code,
    idx_cons_dim.index_id                          AS index_id,
    idx_cons_dim.index_nm                          AS index_nm

FROM {{ ref('dtm_fct_index_constituent_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr sec_dim
    ON sec_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND sec_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND sec_dim.ds_rcrd_st = 'ACTIVE'
LEFT JOIN {{ ref('dtm_index_constituent_dim') }}_hstr idx_cons_dim
    ON idx_cons_dim.index_constituent_dim_id = f.index_constituent_dim_id AND idx_cons_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND idx_cons_dim.ds_rcrd_st = 'ACTIVE'
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
