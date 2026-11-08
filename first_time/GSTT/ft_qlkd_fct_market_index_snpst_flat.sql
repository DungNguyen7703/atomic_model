-- [FIRST-TIME] ft_qlkd_fct_market_index_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily qlkd_fct_market_index_snpst_flat (config ft_target='qlkd_fct_market_index_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : qlkd_fct_market_index_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] Ban FIRST-TIME cua model QLKD (nap 1 nam trong 1 lan chay): bo loc etl_date, doc dim tu bang MAIN. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
SELECT
    -- FACT Market Index Snapshot
    f.snpst_dt_dim_id,
    f.market_index_dim_id,
    f.market_index_val,
    f.open_index,
    f.high_index,
    f.low_index,
    f.prior_index,
    f.index_change,
    f.index_percent_change,
    f.advances_count,
    f.declines_count,
    f.no_change_count,
    f.ceiling_count,
    f.floor_count,
    -- CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,
    -- MARKET INDEX DIMENSION
    idx_dim.market_id               AS market_id,
    idx_dim.market_code             AS market_code,
    idx_dim.index_nm                AS index_nm,
    idx_dim.index_tp_code           AS index_tp_code,
    idx_dim.tsc_product_group_id     AS tsc_product_group_id,
    idx_dim.market_status_code      AS market_status_code,
    idx_dim.src_stm_code             AS market_index_src_stm_code

FROM {{ ft_ref('ft_dtm_fct_market_index_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [BACKFILL-UAT-ORIG] LEFT JOIN {{ ft_ref('ft_dtm_market_index_dim') }}_hstr idx_dim
    -- [BACKFILL-UAT-ORIG] ON idx_dim.market_index_dim_id = f.market_index_dim_id AND idx_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [FIRST-TIME 2026-10-17] dim ft_hstr_by_day: doc _hstr theo DUNG ngay (MAIN chi con snapshot ngay moi nhat nen chi so
-- doi ten/ngung ve sau ra market_code rong o cac ngay cu).
LEFT JOIN {{ ft_ref('ft_dtm_market_index_dim') }}_hstr idx_dim
    ON idx_dim.market_index_dim_id = f.market_index_dim_id AND idx_dim.ds_snpst_dt = cal.cdr_dt AND idx_dim.ds_rcrd_st = 'ACTIVE'
-- [BACKFILL-UAT-ORIG] WHERE cal.cdr_dt = TO_DATE(to_date('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyy-MM-dd')