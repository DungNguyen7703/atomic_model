-- ────────────────────────────────────────────────────────────
-- Model : gsdc_fct_public_company_listed_share_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        public_company_dim_id,
        snpst_dt_dim_id,
        outstanding_share_quantity,
        total_issued_share_quantity,
        treasury_share_quantity,
        free_float_share_quantity
    FROM {{ ref('dtm_fct_public_company_listed_share_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

dim AS (
    SELECT
        public_company_dim_id,
        public_company_code,
        equity_ticker_symbol,
        public_company_nm,
        equity_listing_exchange_code,
        business_line_level_1_code,
        classification_business_line_nm
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
      AND src_stm_code = 'IDS_COMPANY_PROFILES'
)

SELECT
    fact.public_company_dim_id,
    fact.snpst_dt_dim_id,
    fact.outstanding_share_quantity,
    fact.total_issued_share_quantity,
    fact.treasury_share_quantity,
    fact.free_float_share_quantity,
    TO_DATE(fact.snpst_dt_dim_id, 'yyyyMMdd')            AS snpst_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.classification_business_line_nm
FROM fact
LEFT JOIN dim
    ON dim.public_company_dim_id = fact.public_company_dim_id
