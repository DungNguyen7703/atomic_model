-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_training_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────
-- 2026-09-09  duc.luxuan  Theo BA SQL mới nhóm 11: bỏ exam_score/exam_result_code/exam_result_nm
--             (nguồn SPECIALIZATION_COURSE_DETAILS đã bỏ ở dtm_opr_practitioner_training_hist);
--             bổ sung training_result_status_code, training_cl_result_code.
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        training_result_code,
        training_class_code,
        training_class_nm,
        training_start_dt,
        training_end_dt,
        training_hours,
        hours_sufficiency_indicator,
        exam_result_code,
        exam_result_nm,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_training_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    training_result_code,
    training_class_code,
    training_class_nm,
    training_start_dt,
    training_end_dt,
    training_hours,
    hours_sufficiency_indicator,
    exam_result_code,
    exam_result_nm,
    src_stm_code

FROM src 