-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_exam_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        examination_assessment_result_code,
        assessment_nm,
        rpt_year,
        examination_session_nbr,
        examination_period,
        examination_start_dt,
        examination_end_dt,
        law_score,
        specialization_score,
        law_result_code,
        law_result_nm,
        specialization_result_code,
        specialization_result_nm,
        overall_result_code,
        overall_result_nm,
        decision_nbr,
        decision_signed_dt,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_exam_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    examination_assessment_result_code,
    assessment_nm,
    rpt_year,
    examination_session_nbr,
    examination_period,
    examination_start_dt,
    examination_end_dt,
    law_score,
    specialization_score,
    law_result_code,
    law_result_nm,
    specialization_result_code,
    specialization_result_nm,
    overall_result_code,
    overall_result_nm,
    decision_nbr,
    decision_signed_dt,
    src_stm_code

FROM src 