-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_investor_category_trading_snpst_flat
-- Type  : FACT
-- 2026-09-21 tuan.nguyenvanb: [MOI, theo LLD] Flat table cho Fact Investor Category Trading
-- Snapshot - GD theo Phan loai NDT (CA_NHAN/TO_CHUC_TRONG_NUOC/TU_DOANH/NUOC_NGOAI), 4 dong
-- co dinh / ma CK / ngay. Cung pattern denormalize voi gstt_fct_foreign_trading_min_snpst_flat
-- (LEFT JOIN dtm_cdr_dt_dim + dtm_security_trading_snpst_dim).
-- 2026-09-30 tuan.nguyenvanb: [REVIEW LLD] Them f.buy_vol/f.sell_vol (sau buy_val/sell_val, dung vi tri nguon).
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Investor Category Trading Snapshot
    f.security_trading_snpst_dim_id,
    f.snpst_dt_dim_id,
    f.investor_category_code,
    f.buy_val,
    f.buy_vol,
    f.sell_val,
    f.sell_vol,
    f.matched_buy_val,
    f.matched_sell_val,
    f.negotiated_buy_val,
    f.negotiated_sell_val,
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

FROM {{ ref('dtm_fct_investor_category_trading_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr sec_dim
    ON sec_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND sec_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND sec_dim.ds_rcrd_st = 'ACTIVE'
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
