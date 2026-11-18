-- ────────────────────────────────────────────────────────────
-- Model : qlcb_fct_securities_offering_application_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.application_cd,
    f.certificate_dt_dim_id,
    f.application_status_code,
    f.offering_method_dim_id,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')                    AS snpst_cdr_dt,
    to_date(f.certificate_dt_dim_id, 'yyyyMMdd')              AS cdr_dt,
    om.offering_method_code,
    om.offering_method_nm,
    om.offering_method_group_nm,
    om.src_stm_code                        AS offering_method_src_stm_code

FROM {{ ref('dtm_fct_securities_offering_application_snpst') }} f
-- left JOIN {{ ref('dtm_cdr_dt_dim') }} snpst_cal
--     ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- left JOIN {{ ref('dtm_cdr_dt_dim') }} cal
--     ON cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN {{ ref('dtm_offering_method_dim') }}_hstr om
    ON om.offering_method_dim_id = f.offering_method_dim_id AND om.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE to_date(f.snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')