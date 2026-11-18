-- Program code: pttt_fct_sector_risk_snpst_flat
-- Program name: Flat table Fact Sector Risk Snapshot
-- Source mart model: dtm_fct_sector_risk_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date, and dtm_sector_dim for industry code and industry name
-- Grain: 1 row per industry per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Stress score, liquidity score, rating and sector price to earnings, taken as is from the mart.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.industry_dim_id,
    f.total_val_sector,
    f.total_market_cap_sector,
    f.stress_score_sector,
    f.sector_liquid_score,
    f.stress_score_sector_previous_day,
    f.sector_stress_delta,
    f.sector_rating,
    f.sector_debt_score,
    f.total_trading_val_matched_sector,
    f.foreign_net_val_sector,
    f.proprietary_net_val_sector,
    f.total_outstanding_share_quantity_sector,
    f.net_profit_after_tax_amt_sector,
    f.sector_pe,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    sd.industry_code,
    sd.industry_nm
FROM {{ ref('dtm_fct_sector_risk_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_sector_dim') }} sd
    ON sd.sector_dim_id = f.industry_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
