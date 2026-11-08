-- ────────────────────────────────────────────────────────────
-- Model : qlkd_fct_securities_company_capital_raising_event_flat
-- Type  : FACT
-- [SUA 2026-10-24, O_QLKD_54] Bo filter WHERE cal.cdr_dt = thang etl_date -
-- dong bo voi dtm_fct_securities_company_capital_raising_event (nguon nho,
-- ETL nap lai TOAN BO moi thang co du lieu moi lan chay, TRUNCATE + INSERT).
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Securities Company Capital Raising Event
    f.event_dt_dim_id,
    f.offering_form_dim_id,
    f.proceeds_collected_amt,
    -- CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,
    -- OFFERING FORM DIMENSION
    offer_dim.capital_raising_form_code   AS capital_raising_form_code,
    offer_dim.capital_raising_form_nm     AS capital_raising_form_nm,
    offer_dim.src_stm_code                AS offering_form_src_stm_code

FROM {{ ref('dtm_fct_securities_company_capital_raising_event') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.event_dt_dim_id
LEFT JOIN {{ ref('dtm_offering_form_dim') }} offer_dim
    ON offer_dim.offering_form_dim_id = f.offering_form_dim_id