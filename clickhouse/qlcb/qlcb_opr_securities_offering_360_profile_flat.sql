-- ────────────────────────────────────────────────────────────
-- Model : qlcb_opr_securities_offering_360_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    o.securities_offering_code,
    o.offering_method_code,
    cl.cl_nm                            AS offering_method_nm,
    o.public_company_code,
    o.public_company_nm,
    o.equity_ticker_symbol,
    o.securities_tp_code,
    o.total_registered_quantity,
    o.total_expected_amt,
    o.total_successful_quantity,
    o.total_collected_amt,
    o.certificate_nbr,
    o.certificate_dt,
    o.official_letter_nbr,
    o.official_letter_dt,
    o.offering_purpose,
    o.business_line_level_1_code,
    o.classification_business_line_nm,
    o.equity_listing_exchange_code,
    o.consulting_organization_nm,
    o.audit_organization_nm,
    o.underwriting_organization_nm,
    o.credit_rating_organization_nm,
    o.processor_user_nm_snpst,
    o.successful_ratio_percentage,
    o.offering_price,
    o.employee_quantity,
    o.swap_target,
    o.actual_offering_price,
    o.employee_quantity_result,
    o.capital_src,
    o.src_stm_code

FROM {{ ref('dtm_opr_securities_offering_360_profile') }} o
LEFT JOIN atomic.uat_atm.cl_value cl
    ON cl.cl_code = o.offering_method_code AND cl.schema_code = 'SO_OFFERING_METHOD'