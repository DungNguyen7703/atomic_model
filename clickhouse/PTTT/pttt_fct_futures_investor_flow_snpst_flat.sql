-- Program code: pttt_fct_futures_investor_flow_snpst_flat
-- Program name: Flat table Fact Futures Investor Flow Snapshot
-- Source mart model: dtm_fct_futures_investor_flow_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per futures contract per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Foreign and proprietary buy, sell and net volume, taken as is from the mart.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.underlying_symbol,
    f.foreign_buy_vol,
    f.foreign_sell_vol,
    f.foreign_net_vol,
    f.proprietary_buy_vol,
    f.proprietary_sell_vol,
    f.proprietary_net_vol,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_futures_investor_flow_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
