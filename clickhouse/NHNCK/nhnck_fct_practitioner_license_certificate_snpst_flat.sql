-- ────────────────────────────────────────────────────────────
-- Model : nhnck_fct_practitioner_license_certificate_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        practitioner_dim_id,
        issue_dt_dim_id,
        snpst_dt_dim_id,
        certificate_tp_dim_id,
        license_certificate_document_code,
        certificate_nbr,
        is_reissue_indicator,
        certificate_issue_dt,
        revocation_dt,
        decision_tp_code,
        decision_signed_dt,
        certificate_status_code
    FROM {{ ref('dtm_fct_practitioner_license_certificate_snpst') }}
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
),

certificate_tp_dim AS (
    SELECT
        certificate_tp_dim_id,
        certificate_tp_code,
        certificate_tp_nm,
        src_stm_code
    FROM {{ ref('dtm_sp_license_certificate_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    -- FACT Practitioner License Certificate Snapshot
    f.practitioner_dim_id,
    f.issue_dt_dim_id,
    f.snpst_dt_dim_id,
    f.certificate_tp_dim_id,
    f.license_certificate_document_code,
    f.certificate_nbr,
    f.is_reissue_indicator,
    f.certificate_issue_dt,
    f.revocation_dt,
    f.decision_tp_code,
    f.decision_signed_dt,
    f.certificate_status_code,
    TO_DATE(f.snpst_dt_dim_id, 'yyyyMMdd')            AS snpst_cdr_dt,
    TO_DATE(f.issue_dt_dim_id, 'yyyyMMdd')            AS issue_cdr_dt,
    -- SECURITIES PRACTITIONER DIMENSION
    prac_dim.practitioner_code          AS practitioner_code,
    prac_dim.full_nm                    AS practitioner_full_nm,
    prac_dim.education_level_code       AS practitioner_education_level_code,
    prac_dim.education_level_nm         AS practitioner_education_level_nm,
    prac_dim.nationality_code           AS practitioner_nationality_code,
    prac_dim.birth_dt                   AS practitioner_birth_dt,
    prac_dim.practice_status_code       AS practitioner_practice_status_code,
    prac_dim.practice_status_nm         AS practitioner_practice_status_nm,
    prac_dim.src_stm_code               AS practitioner_src_stm_code,
    -- SP LICENSE CERTIFICATE TYPE DIMENSION
    certificate_tp_dim.certificate_tp_code   AS certificate_tp_dim_code,
    certificate_tp_dim.certificate_tp_nm     AS certificate_tp_dim_nm,
    certificate_tp_dim.src_stm_code          AS certificate_tp_src_stm_code

FROM fact f
LEFT JOIN practitioner_dim prac_dim
    ON prac_dim.securities_practitioner_dim_id = f.practitioner_dim_id
LEFT JOIN certificate_tp_dim certificate_tp_dim
    ON certificate_tp_dim.certificate_tp_dim_id = f.certificate_tp_dim_id