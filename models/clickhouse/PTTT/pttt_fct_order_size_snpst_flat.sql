-- Program code: pttt_fct_order_size_snpst_flat
-- Program name: Flat table Fact Order Size Snapshot
-- Source mart model: dtm_fct_order_size_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per security symbol, order size band and trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Since 2026-10-14 each matched trade is classified by its own value against 1 billion VND, then summed. A symbol can have two rows per day. The ClickHouse table is ReplicatedMergeTree, so both rows are kept.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.total_trading_val_matched,
    f.order_size_band,
    f.total_trading_vol_matched,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_order_size_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
