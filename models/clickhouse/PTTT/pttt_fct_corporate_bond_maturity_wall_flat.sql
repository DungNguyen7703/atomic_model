-- Program code: pttt_fct_corporate_bond_maturity_wall_flat
-- Program name: Flat table Fact Corporate Bond Maturity Wall
-- Source mart model: dtm_fct_corporate_bond_maturity_wall
-- Joined dimension: dtm_cdr_dt_dim for calendar date, and dtm_securities_dim for bond attributes such as symbol, issuer and listing date
-- Grain: 1 row per bond, ranking and bond flow for the snapshot day
-- Filter: only rows where data_dt equals etl_date
-- Note: Filter uses data_dt equal to etl_date, not snpst_dt_dim_id. Calendar join is kept only for the broadcast hint.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.securities_dim_id,
    f.ranking_code,
    f.bond_flow_code,
    f.bond_code,
    f.par_val,
    f.outstanding_vol,
    f.bond_outstanding_val,
    f.maturity_dt,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    se_dim.symbol,
    se_dim.security_full_nm,
    se_dim.stock_tp_code,
    se_dim.floor_code,
    se_dim.listed_share_count,
    se_dim.total_listing_vol,
    se_dim.underlying_symbol,
    se_dim.issuer_nm,
    se_dim.listing_dt,
    se_dim.symbol_status_code
FROM {{ ref('dtm_fct_corporate_bond_maturity_wall') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_dim') }} se_dim
    ON se_dim.securities_dim_id = f.securities_dim_id
WHERE f.data_dt = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd')
