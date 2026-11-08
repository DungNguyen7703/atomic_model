-- Program code: pttt_fct_cap_grp_snpst_flat
-- Program name: Flat table Fact Cap Group Snapshot
-- Source mart model: dtm_fct_cap_grp_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per market cap group per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Liquidity share of each cap group, taken as is from the mart.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.cap_group_code,
    f.total_trading_val,
    f.liquidity_share_ratio,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_cap_grp_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
