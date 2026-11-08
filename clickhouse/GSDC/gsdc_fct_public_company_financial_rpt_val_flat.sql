-- ────────────────────────────────────────────────────────────
-- Model : gsdc_fct_public_company_financial_rpt_val_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────
-- 2026-10-02 duc.luxuan: Mart nguon doi kieu (cot chi tieu co so -> Decimal(38,8), cot
-- tinh tu phep chia/% -> Decimal(30,6)) do atm_fr_value.data_val len decimal(38,8).
-- Model pass-through, khong doi SQL. PHAI ALTER TABLE MODIFY COLUMN tren ClickHouse
-- (xem lakehouse_ubck_v1/ddl/20261002_gsdc_decimal_{iceberg,clickhouse}.sql) truoc khi chay job, neu khong JDBC insert se lam tron/tran so.
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        public_company_dim_id,
        financial_rpt_catalog_dim_id,
        snpst_dt_dim_id,
        industry_dim_id,
        rpt_year,
        rpt_quarter,
        row_code,
        column_code,
        data_val
    FROM {{ ref('dtm_fct_public_company_financial_rpt_val') }}
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
),

catalog_dim AS (
    SELECT
        financial_rpt_catalog_dim_id,
        financial_rpt_catalog_code,
        financial_rpt_catalog_nm,
        financial_rpt_catalog_tp_code,
        enterprise_tp_code,
        row_description_reference,
        column_description_reference
    FROM {{ ref('dtm_financial_rpt_catalog_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_REPORT_CATALOG'
)

SELECT
    fact.public_company_dim_id,
    fact.financial_rpt_catalog_dim_id,
    fact.snpst_dt_dim_id,
    fact.industry_dim_id,
    fact.rpt_year,
    fact.rpt_quarter,
    fact.row_code,
    fact.column_code,
    fact.data_val,
    to_date(fact.snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt,
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
    dim.classification_business_line_nm,
    catalog_dim.financial_rpt_catalog_code,
    catalog_dim.financial_rpt_catalog_nm,
    catalog_dim.financial_rpt_catalog_tp_code,
    catalog_dim.enterprise_tp_code       AS fr_catalog_enterprise_tp_code,
    catalog_dim.row_description_reference,
    catalog_dim.column_description_reference
FROM fact
JOIN dim
    ON dim.public_company_dim_id = fact.public_company_dim_id
LEFT JOIN catalog_dim
    ON catalog_dim.financial_rpt_catalog_dim_id = fact.financial_rpt_catalog_dim_id
