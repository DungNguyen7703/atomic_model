-- Program code: pttt_fct_investor_flow_snpst_flat
-- Program name: Flat table Fact Investor Flow Snapshot
-- Source mart model: dtm_fct_investor_flow_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date, and dtm_investor_group_dim for investor group code and name
-- Grain: 1 row per investor group per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: trading_val_ratio is the group share in the total of four exclusive groups, since 2026-10-13. The mart keeps only boards G1, G2, G3, G4, G7 and G8.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.investor_group_dim_id,
    f.buy_val,
    f.sell_val,
    f.net_flow_val,
    f.trading_val_ratio,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    ig.investor_group_code,
    ig.investor_group_nm
FROM {{ ref('dtm_fct_investor_flow_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_investor_group_dim') }} ig
    ON ig.investor_group_dim_id = f.investor_group_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
