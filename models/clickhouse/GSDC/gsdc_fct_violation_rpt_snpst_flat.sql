-- ────────────────────────────────────────────────────────────
-- Model : gsdc_fct_violation_rpt_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fct_violation AS (
    SELECT
        public_company_dim_id,
        snpst_dt_dim_id,
        rpt_year,
        rpt_quarter,
        rpt_due_count,
        rpt_submitted_count,
        to_date(snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
    FROM {{ ref('dtm_fct_violation_rpt_snpst') }}
    WHERE to_date(snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

pc_dim AS (
    SELECT
        public_company_dim_id,
        public_company_code,
        equity_ticker_symbol,
        public_company_nm,
        equity_listing_exchange_code,
        business_line_level_1_code,
        ids_registration_dt,
        public_company_status_code,
        classification_business_line_nm,
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
        ipo_company_indicator
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND ds_rcrd_st = 'ACTIVE'
    AND src_stm_code = 'IDS_COMPANY_PROFILES'
)

SELECT
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.rpt_year,
    f.rpt_quarter,
    f.rpt_due_count,
    f.rpt_submitted_count,
    f.snpst_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.classification_business_line_nm,
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
    dim.ipo_company_indicator

FROM fct_violation f
LEFT JOIN pc_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id