-- Program code: pttt_fct_domestic_individual_net_trade_snpst_flat
-- Program name: Flat table Fact Domestic Individual Net Trade Snapshot
-- Source mart model: dtm_fct_domestic_individual_net_trade_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per security symbol per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Domestic Individual buy, sell and net value (VSDC investor_tp_code = 3).
-- Modified: 2026-11-06 tuan.nguyenvanb: tao moi theo BA top 10 gia tri rong.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.domestic_individual_buy_val,
    f.domestic_individual_sell_val,
    f.domestic_individual_net_val,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_domestic_individual_net_trade_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
