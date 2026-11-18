-- Program code: pttt_fct_corporate_bond_market_snpst_flat
-- Program name: Flat table Fact Corporate Bond Market Snapshot
-- Source mart model: dtm_fct_corporate_bond_market_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per trading day, whole corporate bond market
-- Filter: only the snapshot day equal to etl_date
-- Note: Maturity pressure, outstanding value, trading value and weighted yield, taken as is from the mart.
-- Modified: 2026-10-27 add 6 columns at the end (listed / private split): outstanding_vol_listed/private, bond_outstanding_val_listed/private, maturity_pressure_12_months_listed/private. Needs ALTER on the ClickHouse table.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.par_val,
    f.outstanding_vol,
    f.bond_outstanding_val,
    f.maturity_pressure_12_months,
    f.maturity_pressure_12_months_previous,
    f.maturity_pressure_growth_percentage,
    f.bond_trading_val,
    f.bond_yield_weighted_average,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    f.outstanding_vol_listed,
    f.outstanding_vol_private,
    f.bond_outstanding_val_listed,
    f.bond_outstanding_val_private,
    f.maturity_pressure_12_months_listed,
    f.maturity_pressure_12_months_private
FROM {{ ref('dtm_fct_corporate_bond_market_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
