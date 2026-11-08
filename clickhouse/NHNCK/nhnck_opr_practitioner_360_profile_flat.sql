-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_360_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        full_nm,
        birth_dt,
        age,
        nationality_code,
        nationality_nm,
        identification_nbr,
        identification_tp_code,
        education_level_code,
        education_level_nm,
        workplace_nm,
        practice_status_code,
        practice_status_nm,
        active_certificate_tp_code,
        active_certificate_tp_nm,
        active_certificate_nbr,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_360_profile') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    full_nm,
    birth_dt,
    age,
    nationality_code,
    nationality_nm,
    identification_nbr,
    identification_tp_code,
    education_level_code,
    education_level_nm,
    workplace_nm,
    practice_status_code,
    practice_status_nm,
    active_certificate_tp_code,
    active_certificate_tp_nm,
    active_certificate_nbr,
    src_stm_code

FROM src