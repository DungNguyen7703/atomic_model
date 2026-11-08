-- Program code: pttt_fct_market_statistics_snpst_flat
-- Program name: Flat table Fact Market Statistics Snapshot
-- Source mart model: dtm_fct_market_statistics_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per market code per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Index close price, trading value, earnings per share and price to earnings, taken as is from the mart.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.market_code,
    f.total_trading_vol_matched,
    f.close_price,
    f.close_price_previous_day,
    f.price_change_percentage,
    f.total_trading_val_matched,
    f.total_trading_val_matched_average_50_days,
    f.total_outstanding_share_quantity,
    f.net_profit_after_tax_amt,
    f.idx_eps,
    f.idx_pe,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_market_statistics_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
