-- [FIRST-TIME] ft_ndtnn_fct_foreign_net_flow_market_index_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_fct_foreign_net_flow_market_index_snpst_flat (config ft_target='ndtnn_fct_foreign_net_flow_market_index_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_net_flow_market_index_snpst_flat
-- Type  : FACT
-- 2026-10-12 nghia.le: [FIRST-TIME NDTNN] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- cdr_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay cua tung
-- dong (ft_day_column) -> 1 partition = 1 ngay nhu daily. Dim doc bang MAIN giong daily.
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Foreign Net Flow Market Index Snapshot
    f.snpst_dt_dim_id,
    f.market_index_dim_id,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.foreign_net_trading_val,
    f.market_index_close_val,
    f.foreign_net_capital_flow_mtd_amt,
    -- CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                       AS snpst_cdr_dt,
    -- MARKET INDEX DIMENSION
    mi_dim.market_id                       AS market_id,
    mi_dim.market_code                     AS market_code,
    mi_dim.index_nm                        AS index_nm

FROM {{ ft_ref('ft_dtm_fct_foreign_net_flow_market_index_snpst') }} f   -- [FT-NEW] daily: ref('dtm_fct_foreign_net_flow_market_index_snpst')
JOIN {{ ref('dtm_cdr_dt_dim') }} snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ft_ref('ft_dtm_market_index_dim') }} mi_dim   -- [FT-NEW] daily: ref('dtm_market_index_dim')
    ON mi_dim.market_index_dim_id = f.market_index_dim_id
-- [FT-ORIG] WHERE snpst_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
