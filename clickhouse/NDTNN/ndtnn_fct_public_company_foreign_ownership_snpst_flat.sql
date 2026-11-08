-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_public_company_foreign_ownership_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Public Company Foreign Ownership Snapshot
    f.snpst_dt_dim_id,
    f.public_company_dim_id,
    f.ticker_symbol,
    f.total_issued_share_quantity,
    f.max_foreign_ownership_ratio,
    f.max_foreign_holding_quantity,
    f.current_foreign_holding_quantity,
    f.remaining_foreign_holding_quantity,
    f.src_stm_code,
    f.foreign_holding_value,
    -- CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                       AS snpst_cdr_dt,
    -- PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code             AS public_company_code,
    pc_dim.equity_ticker_symbol            AS equity_ticker_symbol,
    pc_dim.public_company_nm               AS public_company_nm,
    pc_dim.equity_listing_exchange_code    AS equity_listing_exchange_code,
    pc_dim.classification_business_line_nm AS classification_business_line_nm

FROM {{ ref('dtm_fct_public_company_foreign_ownership_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_public_company_dim') }} pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')