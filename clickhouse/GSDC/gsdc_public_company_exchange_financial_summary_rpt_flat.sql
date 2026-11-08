-- ────────────────────────────────────────────────────────────
-- Model : gsdc_public_company_exchange_financial_summary_rpt_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────
-- 2026-10-01 duc.luxuan: bo sung 9 cot % thay doi tu dau nam (<metric>_ytd_chg,
-- debt_to_equity_ytd_diff) dat ngay sau <metric>_yoy tuong ung. INSERT theo vi tri
-- cot => PHAI ALTER TABLE ADD COLUMN ... AFTER tren ClickHouse truoc khi chay job.
-- ────────────────────────────────────────────────────────────
-- 2026-10-02 duc.luxuan: Mart nguon doi kieu (cot chi tieu co so -> Decimal(38,8), cot
-- tinh tu phep chia/% -> Decimal(30,6)) do atm_fr_value.data_val len decimal(38,8).
-- Model pass-through, khong doi SQL. PHAI ALTER TABLE MODIFY COLUMN tren ClickHouse
-- (xem lakehouse_ubck_v1/ddl/20261002_gsdc_decimal_{iceberg,clickhouse}.sql) truoc khi chay job, neu khong JDBC insert se lam tron/tran s
-- ────────────────────────────────────────────────────────────
-- 2026-10-02 duc.luxuan: doi ten debt_to_equity_ytd_diff -> debt_to_equity_ytd_chg (toc do
-- thay doi % so voi dau nam, chot voi BA). PHAI RENAME COLUMN tren ClickHouse truoc khi
-- chay job (xem lakehouse_ubck_v1/ddl/20261002_gsdc_de_ytd_chg.sql).
-- ────────────────────────────────────────────────────────────

SELECT
    equity_listing_exchange_code,
    rpt_year,
    rpt_quarter,
    total_asset_amt,
    total_asset_yoy,
    total_asset_ytd_chg,
    inventory_amt,
    inventory_yoy,
    inventory_ytd_chg,
    total_liability_amt,
    total_liability_yoy,
    total_liability_ytd_chg,
    equity_amt,
    equity_yoy,
    equity_ytd_chg,
    contributed_capital_amt,
    contributed_capital_yoy,
    contributed_capital_ytd_chg,
    undistributed_profit_amt,
    undistributed_profit_yoy,
    undistributed_profit_ytd_chg,
    net_revenue_amt,
    net_revenue_yoy,
    net_revenue_ytd_amt,
    net_revenue_ytd_yoy,
    pre_tax_profit_amt,
    pre_tax_profit_yoy,
    pre_tax_profit_ytd_amt,
    pre_tax_profit_ytd_yoy,
    net_profit_amt,
    net_profit_yoy,
    net_profit_ytd_amt,
    net_profit_ytd_yoy,
    roa_percentage,
    roa_yoy_percentage,
    roa_ytd_percentage,
    roa_ytd_yoy_percentage,
    roe_percentage,
    roe_yoy_percentage,
    roe_ytd_percentage,
    roe_ytd_yoy_percentage,
    receivable_amt,
    receivable_yoy,
    receivable_ytd_chg,
    cash_and_equivalent_amt,
    cash_and_equivalent_yoy,
    cash_and_equivalent_ytd_chg,
    debt_to_equity,
    debt_to_equity_yoy,
    debt_to_equity_ytd_chg,
    src_stm_code,
    rpt_dt

FROM {{ ref('dtm_public_company_exchange_financial_summary_rpt') }} 
WHERE rpt_dt = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')