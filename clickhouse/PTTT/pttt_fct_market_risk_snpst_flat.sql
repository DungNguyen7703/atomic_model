-- Program code: pttt_fct_market_risk_snpst_flat
-- Program name: Flat table Fact Market Risk Snapshot
-- Source mart model: dtm_fct_market_risk_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per trading day, whole market
-- Filter: only the snapshot day equal to etl_date
-- Note: All logic is in the mart, this flat only passes columns through. turnover_velocity_index is a one day value since 2026-10-14 and its ClickHouse type is Decimal 18,10.
-- Modified: 2026-10-15 add header comment, no logic change
-- Modified: 2026-11-02 tuan.nguyenvanb: add margin_period_end_dt (month of total_margin_balance) after turnover_velocity_status, before snpst_cdr_dt. Needs ALTER ADD COLUMN AFTER on the ClickHouse table.
-- Modified: 2026-10-23 LLD 20 session window: rename volatility_30_days, net_flow_foreign_average_30_days and net_flow_proprietary_average_30_days to *_20_days, drop total_market_cap_vsdc_average_n_days. Needs ALTER on the ClickHouse table.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.volatility_20_days,
    f.z_score_volatility,
    f.z_score_liquidity,
    f.z_score_margin_balance,
    f.z_score_interbank_rate,
    f.z_score_foreign_net_flow,
    f.total_market_cap,
    f.beta_volatility,
    f.beta_liquidity,
    f.beta_margin_balance,
    f.beta_interbank_rate,
    f.beta_foreign_net_flow,
    f.beta_equity_capital_raising,
    f.beta_intercept,
    f.epsilon_error_term,
    f.risk_index,
    f.z_score_equity_capital_raising,
    f.equity_capital_raising_amt,
    f.margin_to_cap_ratio_stddev,
    f.margin_to_cap_ratio_current,
    f.margin_to_cap_ratio_avg,
    f.total_margin_balance,
    f.index_log_return,
    f.illiquidity_ratio,
    f.foreign_net_flow,
    f.vnindex_val,
    f.weight_liquidity,
    f.weight_stability,
    f.sentiment_index,
    f.sentiment_index_status,
    f.margin_tension,
    f.margin_tension_status,
    f.vnindex_daily_return,
    f.systemic_vol_current,
    f.systemic_vol_max,
    f.systemic_vol,
    f.systemic_vol_status,
    f.vnindex_val_previous_day,
    f.vnindex_daily_return_average,
    f.index_val_monthly_average,
    f.total_trading_val_matched,
    f.total_trading_val_matched_previous_day,
    f.total_order_count_matched,
    f.average_order_size,
    f.total_trading_vol_matched,
    f.total_trading_val_matched_average_50_days,
    f.total_trading_val_matched_average_n_days,
    f.net_flow_foreign_average_20_days,
    f.net_flow_proprietary_average_20_days,
    f.net_flow_correlation_foreign_proprietary,
    f.total_margin_limit_amt,
    f.margin_stress,
    f.margin_stress_status,
    f.margin_balance_delta,
    f.corr_index_interbank_rate,
    f.corr_index_dxy,
    f.total_market_cap_vsdc,
    f.turnover_velocity_index,
    f.turnover_velocity_status,
    f.margin_period_end_dt,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_market_risk_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
