-- ────────────────────────────────────────────────────────────
-- Model : gsdc_industry_flat
-- Type  : Dimension
-- ────────────────────────────────────────────────────────────

SELECT
    industry_code,
    industry_nm,
    src_stm_code 

FROM {{ ref('dtm_industry_dim')}}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND ds_rcrd_st = 'ACTIVE'
    AND src_stm_code = 'ECAT_BUSINESS_LINE_LEVEL_1'