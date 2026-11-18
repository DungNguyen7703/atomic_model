-- ────────────────────────────────────────────────────────────
-- Model : qlkd_fct_securities_company_service_assignment_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Securities Company Service Assignment Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.securities_service_cl_dim_id,
    f.license_nbr,
    f.license_dt,
    f.start_dt,
    f.end_dt,
    f.src_stm_code,
    -- CALENDAR DATE DIMENSION (Snapshot Date)
    cal.cdr_dt                         AS cdr_dt,
    -- SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.sc_short_nm                 AS sc_short_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm,
    sc_dim.src_stm_code                AS securities_company_src_stm_code,
    -- SECURITIES SERVICE CLASSIFICATION DIMENSION
    svc_dim.cl_sc_firm_service_code    AS cl_sc_firm_service_code,
    svc_dim.cl_sc_firm_service_nm      AS cl_sc_firm_service_nm,
    svc_dim.description                AS description,
    svc_dim.catalog_tp                 AS catalog_tp,
    svc_dim.catalog_code               AS catalog_code,
    svc_dim.application_tp_code        AS application_tp_code,
    svc_dim.legal_capital_amt          AS legal_capital_amt,
    svc_dim.src_stm_code                AS securities_service_cl_src_stm_code

FROM {{ ref('dtm_fct_securities_company_service_assignment_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }} sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
LEFT JOIN {{ ref('dtm_securities_service_cl_dim') }} svc_dim
    ON svc_dim.securities_service_cl_dim_id = f.securities_service_cl_dim_id
WHERE cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')