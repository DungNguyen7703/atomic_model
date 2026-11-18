-- Program code: pttt_fct_futures_intraday_snpst_flat
-- Program name: Flat table Fact Futures Intraday Snapshot
-- Source mart model: dtm_fct_futures_intraday_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per futures contract per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: maturity_month_year is stored as text in the format yyyyMM, for example 202609. Underlying symbol is VN30, VN100 or a government bond index.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.underlying_symbol,
    f.maturity_month_year,
    f.close_price,
    f.reference_price,
    f.price_change_percentage,
    f.total_trading_vol_matched,
    f.total_trading_vol_matched_average_50_days,
    f.liquidity_spike_ratio,
    f.open_interest_quantity,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_futures_intraday_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
