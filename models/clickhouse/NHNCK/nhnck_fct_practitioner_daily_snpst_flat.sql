-- ────────────────────────────────────────────────────────────
-- Model : nhnck_fct_practitioner_daily_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        practitioner_dim_id,
        snpst_dt_dim_id,
        age,
        has_active_violation,
        first_license_dt,
        practicing_indicator,
        concurrent_employment_indicator,
        insufficient_training_indicator,
        no_practice_3_years_indicator
    FROM {{ ref('dtm_fct_practitioner_daily_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
),

practitioner_dim AS (
    SELECT
        securities_practitioner_dim_id,
        practitioner_code,
        full_nm,
        education_level_code,
        education_level_nm,
        nationality_code,
        birth_dt,
        practice_status_code,
        practice_status_nm,
        src_stm_code
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    -- FACT Practitioner Daily Snapshot
    f.practitioner_dim_id,
    f.snpst_dt_dim_id,
    f.age,
    f.has_active_violation,
    f.first_license_dt,
    f.practicing_indicator,
    f.concurrent_employment_indicator,
    f.insufficient_training_indicator,
    f.no_practice_3_years_indicator,
    TO_DATE(f.snpst_dt_dim_id, 'yyyyMMdd')           AS snpst_cdr_dt,
    -- SECURITIES PRACTITIONER DIMENSION
    prac_dim.practitioner_code          AS practitioner_code,
    prac_dim.full_nm                    AS practitioner_full_nm,
    prac_dim.education_level_code       AS practitioner_education_level_code,
    prac_dim.education_level_nm         AS practitioner_education_level_nm,
    prac_dim.nationality_code           AS practitioner_nationality_code,
    prac_dim.birth_dt                   AS practitioner_birth_dt,
    prac_dim.practice_status_code       AS practitioner_practice_status_code,
    prac_dim.practice_status_nm         AS practitioner_practice_status_nm,
    prac_dim.src_stm_code               AS practitioner_src_stm_code

FROM fact f
LEFT JOIN practitioner_dim prac_dim
    ON prac_dim.securities_practitioner_dim_id = f.practitioner_dim_id