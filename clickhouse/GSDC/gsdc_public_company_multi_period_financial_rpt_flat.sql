-- ────────────────────────────────────────────────────────────
-- Model : gsdc_public_company_multi_period_financial_rpt_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    rpt_year,
    rpt_quarter,
    total_asset_amt_year_n,
    total_liability_amt_year_n,
    equity_amt_year_n,
    charter_capital_amt_year_n,
    net_profit_amt_year_n,
    net_profit_ytd_amt_year_n,
    roa_percentage_year_n,
    roa_ytd_percentage_year_n,
    roe_percentage_year_n,
    roe_ytd_percentage_year_n,
    total_asset_amt_year_n1,
    total_liability_amt_year_n1,
    equity_amt_year_n1,
    charter_capital_amt_year_n1,
    net_profit_amt_year_n1,
    net_profit_ytd_amt_year_n1,
    roa_percentage_year_n1,
    roa_ytd_percentage_year_n1,
    roe_percentage_year_n1,
    roe_ytd_percentage_year_n1,
    total_asset_amt_year_n2,
    total_liability_amt_year_n2,
    equity_amt_year_n2,
    charter_capital_amt_year_n2,
    net_profit_amt_year_n2,
    net_profit_ytd_amt_year_n2,
    roa_percentage_year_n2,
    roa_ytd_percentage_year_n2,
    roe_percentage_year_n2,
    roe_ytd_percentage_year_n2,
    src_stm_code,
    rpt_dt

FROM {{ ref('dtm_public_company_multi_period_financial_rpt') }} 
WHERE rpt_dt = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')