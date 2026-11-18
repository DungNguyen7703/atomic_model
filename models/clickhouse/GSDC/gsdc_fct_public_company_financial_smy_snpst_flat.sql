-- ────────────────────────────────────────────────────────────
-- Model : gsdc_fct_public_company_financial_smy_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────
-- 2026-09-15 duc.luxuan: bo sung net_profit_ytd, net_revenue_ytd, pre_tax_profit_ytd,
-- roa_ytd, roe_ytd (chi tieu luy ke tu dau nam, theo yeu cau BA). Model nay dung
-- incremental_strategy=ck_snapshot tren ClickHouse - KHONG tu schema evolution,
-- phai ALTER TABLE ADD COLUMN thu cong tren ClickHouse truoc khi deploy/dbt run.
-- ────────────────────────────────────────────────────
-- 2026-09-21 duc.luxuan: doi kieu cot roa, roe, roa_ytd, roe_ytd, debt_to_equity
-- tu Decimal(9,4) sang Decimal(35,2) - cot dich cu qua nho, tran so (CAST_OVERFLOW)
-- khi mau so (total_asset/equity) gan 0 nhung khac 0. PHAI ALTER TABLE MODIFY COLUMN
-- thu cong tren ClickHouse TRUOC khi chay lai job nay (xem changelog tuong ung
-- 2026-09-21 trong dtm_fct_public_company_financial_smy_snpst.sql).
-- ────────────────────────────────────────────────────────────
-- 2026-10-01 duc.luxuan: bo sung 7 cot dau ky tu dtm_fct_public_company_financial_smy_snpst:
-- total_liability_beginning, contributed_capital_beginning, inventory_beginning,
-- undistributed_profit_beginning, receivable_beginning, cash_and_equivalent_beginning
-- (sau equity_beginning) va debt_to_equity_beginning (sau debt_to_equity). INSERT theo vi tri
-- cot => PHAI ALTER TABLE ADD COLUMN ... AFTER thu cong tren ClickHouse truoc khi chay job.
-- ────────────────────────────────────────────────────────────
-- 2026-11-06 duc.luxuan: dong bo LLD 2026-11-03/04: bo sung 16 cot cuoi fact tu
-- dtm_fct_public_company_financial_smy_snpst (operating_cash_flow, short_term_asset, short_term_liability,
-- interest_expense, financial_revenue, other_revenue, current_ratio, interest_coverage,
-- financial_revenue_to_net_profit, other_revenue_to_net_profit + 6 cot *_ytd), dat sau
-- debt_to_equity_beginning (truoc snpst_cdr_dt). INSERT theo vi tri cot => PHAI ALTER TABLE ADD COLUMN
-- ... AFTER thu cong tren ClickHouse truoc khi chay job.
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        public_company_dim_id,
        snpst_dt_dim_id,
        industry_dim_id,
        rpt_year,
        rpt_quarter,
        total_asset,
        total_liability,
        equity,
        contributed_capital,
        net_profit,
        pre_tax_profit,
        net_profit_ytd,
        net_revenue_ytd,
        pre_tax_profit_ytd,
        total_asset_beginning,
        equity_beginning,
        total_liability_beginning,
        contributed_capital_beginning,
        inventory_beginning,
        undistributed_profit_beginning,
        receivable_beginning,
        cash_and_equivalent_beginning,
        inventory,
        net_revenue,
        undistributed_profit,
        receivable,
        cash_and_equivalent,
        roa,
        roe,
        roa_ytd,
        roe_ytd,
        debt_to_equity,
        debt_to_equity_beginning,
        operating_cash_flow,
        short_term_asset,
        short_term_liability,
        interest_expense,
        financial_revenue,
        other_revenue,
        current_ratio,
        interest_coverage,
        financial_revenue_to_net_profit,
        other_revenue_to_net_profit,
        interest_expense_ytd,
        financial_revenue_ytd,
        other_revenue_ytd,
        interest_coverage_ytd,
        financial_revenue_to_net_profit_ytd,
        other_revenue_to_net_profit_ytd
    FROM {{ ref('dtm_fct_public_company_financial_smy_snpst') }}
    WHERE to_date(snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

dim AS (
    SELECT
        public_company_dim_id,
        public_company_code,
        equity_ticker_symbol,
        public_company_nm,
        equity_listing_exchange_code,
        ids_registration_dt,
        public_company_status_code,
        public_company_english_nm,
        enterprise_tp_code,
        enterprise_tp_nm,
        public_company_tp_code,
        head_office_province_nm,
        operating_status_code,
        has_state_ownership_indicator,
        charter_capital_amt,
        first_registration_dt,
        latest_registration_dt,
        latest_registration_province_nm,
        ids_registration_indicator,
        public_company_form_code,
        former_state_owned_indicator,
        foreign_direct_investment_indicator,
        has_parent_company_indicator,
        has_subsidiary_indicator,
        has_joint_venture_indicator,
        ipo_company_indicator,
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
    fact.industry_dim_id,
    fact.rpt_year,
    fact.rpt_quarter,
    fact.total_asset,
    fact.total_liability,
    fact.equity,
    fact.contributed_capital,
    fact.net_profit,
    fact.pre_tax_profit,
    fact.net_profit_ytd,
    fact.net_revenue_ytd,
    fact.pre_tax_profit_ytd,
    fact.total_asset_beginning,
    fact.equity_beginning,
    fact.total_liability_beginning,
    fact.contributed_capital_beginning,
    fact.inventory_beginning,
    fact.undistributed_profit_beginning,
    fact.receivable_beginning,
    fact.cash_and_equivalent_beginning,
    fact.inventory,
    fact.net_revenue,
    fact.undistributed_profit,
    fact.receivable,
    fact.cash_and_equivalent,
    fact.roa,
    fact.roe,
    fact.roa_ytd,
    fact.roe_ytd,
    fact.debt_to_equity,
    fact.debt_to_equity_beginning,
    fact.operating_cash_flow,
    fact.short_term_asset,
    fact.short_term_liability,
    fact.interest_expense,
    fact.financial_revenue,
    fact.other_revenue,
    fact.current_ratio,
    fact.interest_coverage,
    fact.financial_revenue_to_net_profit,
    fact.other_revenue_to_net_profit,
    fact.interest_expense_ytd,
    fact.financial_revenue_ytd,
    fact.other_revenue_ytd,
    fact.interest_coverage_ytd,
    fact.financial_revenue_to_net_profit_ytd,
    fact.other_revenue_to_net_profit_ytd,
    to_date(fact.snpst_dt_dim_id, 'yyyyMMdd')            AS snpst_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator,
    dim.business_line_level_1_code,
    dim.classification_business_line_nm
FROM fact
LEFT JOIN dim
    ON dim.public_company_dim_id = fact.public_company_dim_id
