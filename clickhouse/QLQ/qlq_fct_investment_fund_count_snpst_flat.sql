-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_investment_fund_count_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        snpst_dt_dim_id,
        fund_type_id,
        fund_count,
        charter_capital_amt,
        src_stm_code
    FROM {{ ref('dtm_fct_investment_fund_count_snpst') }}
),

dim_fund_type AS (
    SELECT
        fund_type_id,
        fund_type_code,
        fund_type_nm,
        open_fund_indicator
    FROM {{ ref('dtm_fund_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
      AND src_stm_code = 'FMS_FUND_TYPE'
)

SELECT
    -- FACT Fact Investment Fund Count Snapshot
    f.snpst_dt_dim_id,
    f.fund_type_id,
    f.fund_count,
    f.charter_capital_amt,
    f.src_stm_code,
    TO_DATE(f.snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt,
    -- FUND TYPE DIMENSION
    ft.fund_type_code,
    ft.fund_type_nm,
    ft.open_fund_indicator

FROM fact f
LEFT JOIN dim_fund_type ft
    ON ft.fund_type_id = f.fund_type_id

