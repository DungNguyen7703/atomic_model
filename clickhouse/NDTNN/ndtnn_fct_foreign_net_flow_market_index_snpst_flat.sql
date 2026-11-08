-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_net_flow_market_index_snpst_flat
-- Type  : FACT
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

FROM {{ ref('dtm_fct_foreign_net_flow_market_index_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_market_index_dim') }} mi_dim
    ON mi_dim.market_index_dim_id = f.market_index_dim_id
WHERE snpst_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')