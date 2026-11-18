-- Program code: pttt_fct_proprietary_net_trade_snpst_flat
-- Program name: Flat table Fact Proprietary Net Trade Snapshot
-- Source mart model: dtm_fct_proprietary_net_trade_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per security symbol per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Proprietary buy, sell and net value. The mart keeps only boards G1, G2, G3, G4, G7 and G8 since 2026-10-13.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.proprietary_buy_val,
    f.proprietary_sell_val,
    f.proprietary_net_val,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_proprietary_net_trade_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
