-- ────────────────────────────────────────────────────────────
-- Model : qlkd_fct_market_index_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

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

FROM {{ ref('dtm_fct_market_index_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [2026-10-20] Doc dim _hstr DUNG ngay snapshot (khong doc MAIN): chi so doi ten/ngung/INACTIVE o MAIN van ra dung ten theo ngay (VD VNDIVIDEND index_nm rong khi doc MAIN).
LEFT JOIN {{ ref('dtm_market_index_dim') }}_hstr idx_dim
    ON idx_dim.market_index_dim_id = f.market_index_dim_id
    AND idx_dim.ds_snpst_dt = cal.cdr_dt
    AND idx_dim.ds_rcrd_st = 'ACTIVE'
WHERE cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')