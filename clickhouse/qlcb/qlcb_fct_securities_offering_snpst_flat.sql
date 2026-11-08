-- ────────────────────────────────────────────────────────────
-- Model : qlcb_fct_securities_offering_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.certificate_dt_dim_id,
    f.public_company_dim_id,
    f.total_expected_amt,
    f.total_collected_amt,
    f.official_letter_dt,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')                    AS snpst_cdr_dt,
    to_date(f.certificate_dt_dim_id, 'yyyyMMdd')              AS cdr_dt,
    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,
    pc.classification_business_line_nm     AS classification_business_line_nm,
    pc.public_company_english_nm           AS public_company_english_nm,
    pc.enterprise_tp_code                  AS enterprise_tp_code,
    pc.public_company_tp_code              AS public_company_tp_code,
    pc.head_office_province_nm             AS head_office_province_nm,
    pc.operating_status_code               AS operating_status_code,
    pc.has_state_ownership_indicator       AS has_state_ownership_indicator,
    pc.charter_capital_amt                 AS charter_capital_amt,
    pc.first_registration_dt               AS first_registration_dt,
    pc.latest_registration_dt              AS latest_registration_dt,
    pc.latest_registration_province_nm     AS latest_registration_province_nm,
    pc.ids_registration_indicator          AS ids_registration_indicator,
    pc.public_company_form_code            AS public_company_form_code,
    pc.former_state_owned_indicator        AS former_state_owned_indicator,
    pc.foreign_direct_investment_indicator AS foreign_direct_investment_indicator,
    pc.has_parent_company_indicator        AS has_parent_company_indicator,
    pc.has_subsidiary_indicator            AS has_subsidiary_indicator,
    pc.has_joint_venture_indicator         AS has_joint_venture_indicator,
    pc.ipo_company_indicator               AS ipo_company_indicator,
    pc.src_stm_code                        AS public_company_src_stm_code

FROM {{ ref('dtm_fct_securities_offering_snpst') }} f
-- JOIN {{ ref('dtm_cdr_dt_dim') }} snpst_cal
--     ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- JOIN {{ ref('dtm_cdr_dt_dim') }} cal
--     ON cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN {{ ref('dtm_public_company_dim') }} pc
    ON pc.public_company_dim_id = f.public_company_dim_id
WHERE to_date(f.snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
and pc.classification_business_line_nm is not null