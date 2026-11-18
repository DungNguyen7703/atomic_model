-- Program code: pttt_fct_corporate_bond_sector_snpst_flat
-- Program name: Flat table Fact Corporate Bond Sector Snapshot
-- Source mart model: dtm_fct_corporate_bond_sector_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date, and dtm_corp_bond_industry_dim for industry code and industry name
-- Grain: 1 row per bond industry per trading day
-- Filter: only the snapshot day equal to etl_date
-- Note: Outstanding value and ratio by industry, taken as is from the mart.
-- Modified: 2026-10-15 add header comment, no logic change
-- Modified: 2026-11-10 industry NULL -> industry_code NA / industry_nm "Chua phan nganh"

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.corp_bond_industry_dim_id,
    f.bond_outstanding_val,
    f.bond_outstanding_val_total,
    f.bond_outstanding_ratio,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    COALESCE(cbi.industry_code, 'NA')                  AS industry_code,
    COALESCE(cbi.industry_nm, 'Chưa phân ngành')       AS industry_nm   -- [2026-11-10] trai phieu chua phan nganh (dim NULL) -> 1 dong "Chua phan nganh"
FROM {{ ref('dtm_fct_corporate_bond_sector_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_corp_bond_industry_dim') }} cbi
    ON cbi.corp_bond_industry_dim_id = f.corp_bond_industry_dim_id
    AND cbi.src_stm_code = 'IDS_CATEGORIES'  -- [2026-10-29] tranh nhan dong do ban ghi dim tu nguon cu
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
