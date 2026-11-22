-- ────────────────────────────────────────────────────────────
-- Model : qlcb_fct_securities_offering_detail_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────


SELECT
    securities_offering_code,
    public_company_nm,
    classification_business_line_nm,
    equity_ticker_symbol,
    securities_tp_code,
    securities_tp_nm,
    certificate_dt,
    official_letter_dt,
    cdr_dt,
    offering_method_nm,
    consulting_organization_nm,
    audit_organization_nm,
    underwriting_organization_nm,
    credit_rating_organization_nm,
    total_registered_quantity,
    total_successful_quantity,
    total_collected_amt,
    total_expected_amt,
    successful_ratio_percentage

FROM {{ ref('dtm_fct_securities_offering_detail_snpst') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

-- SELECT
--     securities_offering_code,
--     public_company_nm,
--     classification_business_line_nm,
--     equity_ticker_symbol,
--     securities_tp_code,
--     securities_tp_nm,
--     certificate_dt,
--     offering_method_nm,
--     consulting_organization_nm,
--     audit_organization_nm,
--     underwriting_organization_nm,
--     credit_rating_organization_nm,
--     total_registered_quantity,
--     total_successful_quantity,
--     total_collected_amt,
--     total_expected_amt,
--     cdr_dt,
--     successful_ratio_percentage

-- FROM {{ ref('dtm_fct_securities_offering_detail_snpst') }}
-- WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

