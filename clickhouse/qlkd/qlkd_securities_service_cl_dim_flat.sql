-- ────────────────────────────────────────────────────────────
-- Model : qlkd_securities_service_cl_dim_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- DIMENSION Securities Service Classification Dimension
    d.securities_service_cl_dim_id,
    d.cl_sc_firm_service_code,
    d.cl_sc_firm_service_nm,
    d.description,
    d.catalog_tp,
    d.catalog_code,
    d.application_tp_code,
    d.legal_capital_amt,
    d.src_stm_code

FROM {{ ref('dtm_securities_service_cl_dim') }} d