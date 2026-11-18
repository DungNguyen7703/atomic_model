-- [FIRST-TIME] ft_gstt_fct_investor_category_index_trading_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_fct_investor_category_index_trading_snpst_flat (config ft_target='gstt_fct_investor_category_index_trading_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_investor_category_index_trading_snpst_flat
-- Type  : FACT
-- 2026-09-23 tuan.nguyenvanb: [MOI, theo LLD] Flat table cho Fact Investor Category Index
-- Trading Snapshot - GD theo Phan loai NDT (CA_NHAN/TO_CHUC_TRONG_NUOC/TU_DOANH/NUOC_NGOAI)
-- cua ca ro chi so, 4 dong co dinh / chi so / ngay. Cung pattern denormalize voi
-- gstt_fct_investor_category_trading_snpst_flat (LEFT JOIN dtm_cdr_dt_dim), nhung dung
-- Index Constituent Dimension thay vi Security Trading Snapshot Dimension.
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
-- Dong goc giu o dang comment BACKFILL-UAT-ORIG. Revert: bo comment BACKFILL-UAT-ORIG va xoa dong BACKFILL-UAT-NEW (hoac chuyen che do daily bang first_time_mode.py). [BACKFILL-UAT-NEW]
-- ────────────────────────────────────────────────────────────

-- [BACKFILL-UAT-ORIG] SELECT /*+ BROADCAST(cal) */
SELECT /*+ BROADCAST(cal), REPARTITION(64, f.snpst_dt_dim_id) */   -- [BACKFILL-UAT-NEW] chia du lieu thanh 64 task theo ngay: moi block INSERT vao ClickHouse chi cham vai chuc partition cdr_dt (tranh Code 252 TOO_MANY_PARTS khi 1 task ghi >100 partition)
    -- FACT Investor Category Index Trading Snapshot
    f.index_constituent_dim_id,
    f.snpst_dt_dim_id,
    f.investor_category_code,
    f.buy_val,
    f.buy_vol,   -- [2026-10-16 LLD]
    f.sell_val,
    f.sell_vol,   -- [2026-10-16 LLD]
    f.matched_buy_val,
    f.matched_sell_val,
    f.negotiated_buy_val,
    f.negotiated_sell_val,
    f.market_index_val,
    f.index_change,
    f.index_percent_change,
    -- CALENDAR DATE
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date,
    -- INDEX CONSTITUENT DIMENSION
    idx_dim.index_code                     AS index_code,
    idx_dim.index_id                       AS index_id,
    idx_dim.index_nm                       AS index_nm,
    idx_dim.src_stm_code                   AS index_constituent_src_stm_code

FROM {{ ft_ref('ft_dtm_fct_investor_category_index_trading_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [BACKFILL-UAT-ORIG] LEFT JOIN {{ ft_ref('ft_dtm_index_constituent_dim') }}_hstr idx_dim
LEFT JOIN {{ ft_ref('ft_dtm_index_constituent_dim') }}_hstr idx_dim   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN (ma INACTIVE o MAIN -> rong)
    ON idx_dim.index_constituent_dim_id = f.index_constituent_dim_id
    -- [BACKFILL-UAT-ORIG] AND idx_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND idx_dim.ds_snpst_dt = to_date(f.snpst_dt_dim_id, 'yyyyMMdd')   -- [FIRST-TIME 2026-10-18]
    AND idx_dim.ds_rcrd_st = 'ACTIVE'
-- [BACKFILL-UAT-ORIG] WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI bo loc WHERE theo etl_date de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
