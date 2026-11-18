-- ────────────────────────────────────────────────────────────
-- Model : gsdc_public_company_financial_yoy_rpt_flat
-- Type  : OPERATIONAL
-- Doi ten 2026-09-18 -> gsdc_public_company_exchange_financial_yoy_rpt_flat, roi
-- rollback 2026-09-19 ve lai ten goc: mart source da gop chieu nganh
-- (business_line_level_1_code/name) vao chung 1 bang cross-tab thay vi tach bang
-- rieng cho nganh (xem changelog trong dtm_public_company_financial_yoy_rpt.sql).
-- Bo sung 2 cot pass-through business_line_level_1_code/business_line_level_1_name
-- de phuc vu dashboard: chon bo loc san -> breakdown theo nganh.
-- ────────────────────────────────────────────────────────────

SELECT
    equity_listing_exchange_code,
    business_line_level_1_code,
    business_line_level_1_name,
    rpt_year,
    rpt_quarter,
    total_asset_yoy,
    total_liability_yoy,
    equity_yoy,
    contributed_capital_yoy,
    net_profit_yoy,
    net_profit_ytd_yoy,
    pre_tax_profit_yoy,
    pre_tax_profit_ytd_yoy,
    inventory_yoy,
    net_revenue_yoy,
    net_revenue_ytd_yoy,
    undistributed_profit_yoy,
    receivable_yoy,
    cash_and_equivalent_yoy,
    roa_yoy,
    roa_ytd_yoy,
    roe_yoy,
    roe_ytd_yoy,
    debt_to_equity_yoy,
    src_stm_code,
    rpt_dt

FROM {{ ref('dtm_public_company_financial_yoy_rpt') }}
WHERE rpt_dt = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
