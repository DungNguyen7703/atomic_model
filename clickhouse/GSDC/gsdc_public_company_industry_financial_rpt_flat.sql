-- ────────────────────────────────────────────────────────────
-- Model : gsdc_public_company_industry_financial_rpt_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────
-- 2026-10-01 duc.luxuan: bo 11 cot *_yoy theo Mart (bang nganh khong thong ke % thay doi).
-- INSERT theo vi tri cot => PHAI ALTER TABLE DROP COLUMN tren ClickHouse truoc khi chay job.
-- 2026-11-06 duc.luxuan: bo sung reported_company_qty_year_n, reported_company_qty_year_n1 (so cong ty
-- da ghi nhan du lieu bao cao, O_GSDC y/c dev 2026-11-03), dat sau roe_ytd_percentage_year_n1.
-- INSERT theo vi tri cot => PHAI ALTER TABLE ADD COLUMN ... AFTER tren ClickHouse truoc khi chay job.
-- ────────────────────────────────────────────────────────────

SELECT
    business_line_level_1_code,
    business_line_level_1_name,
    rpt_year,
    rpt_quarter,
    net_revenue_amt_year_n,
    net_revenue_ytd_amt_year_n,
    net_profit_amt_year_n,
    net_profit_ytd_amt_year_n,
    roa_percentage_year_n,
    roa_ytd_percentage_year_n,
    roe_percentage_year_n,
    roe_ytd_percentage_year_n,
    total_asset_amt_year_n,
    total_liability_amt_year_n,
    equity_amt_year_n,
    contributed_capital_amt_year_n,
    pre_tax_profit_amt_year_n,
    pre_tax_profit_ytd_amt_year_n,
    inventory_amt_year_n,
    undistributed_profit_amt_year_n,
    receivable_amt_year_n,
    cash_and_equivalent_amt_year_n,
    debt_to_equity_year_n,
    net_revenue_amt_year_n1,
    net_revenue_ytd_amt_year_n1,
    net_profit_amt_year_n1,
    net_profit_ytd_amt_year_n1,
    roa_percentage_year_n1,
    roa_ytd_percentage_year_n1,
    roe_percentage_year_n1,
    roe_ytd_percentage_year_n1,
    reported_company_qty_year_n,
    reported_company_qty_year_n1,
    src_stm_code,
    rpt_dt

FROM {{ ref('dtm_public_company_industry_financial_rpt') }} 
WHERE rpt_dt = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')