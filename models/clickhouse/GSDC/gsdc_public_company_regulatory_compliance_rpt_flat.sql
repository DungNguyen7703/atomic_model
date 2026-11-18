-- ────────────────────────────────────────────────────────────
-- Model : gsdc_public_company_regulatory_compliance_rpt_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    equity_listing_exchange_code,
    rpt_year,
    rpt_quarter,
    company_count,
    company_due_count,
    company_submitted_count,
    large_scale_company_count,
    profitable_company_count_year,
    profitable_company_count_ytd,
    src_stm_code,
    rpt_dt

FROM {{ ref('dtm_public_company_regulatory_compliance_rpt') }} 
WHERE rpt_dt = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')