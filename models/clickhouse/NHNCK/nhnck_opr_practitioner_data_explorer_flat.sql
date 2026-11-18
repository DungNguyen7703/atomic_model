-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_data_explorer_flat
-- Type  : OPERATIONAL
-- (Sửa 2026-11-07, O_NHNCK_47) 1-1 từ mart dtm_opr_practitioner_data_explorer — JOIN 360 Profile x Certificate/Exam/
--  Violation History x Fact Daily Snapshot đã thực hiện ở ETL Datamart, flat không JOIN lại.
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_data_explorer_id,
        practitioner_code,
        license_certificate_document_code,
        examination_assessment_result_code,
        conduct_violation_code,
        full_nm,
        birth_dt,
        age,
        nationality_nm,
        identification_nbr,
        identification_tp_code,
        education_level_nm,
        practice_status_code,
        practice_status_nm,
        certificate_nbr,
        certificate_tp_code,
        certificate_tp_nm,
        issue_dt,
        current_organization_nm,
        concurrent_employment_indicator,
        insufficient_training_indicator,
        no_practice_3_years_indicator,
        exam_assessment_nm,
        exam_examination_period,
        exam_examination_start_dt,
        exam_examination_end_dt,
        exam_overall_result_nm,
        violation_decision_nbr,
        violation_decision_signed_dt,
        violation_note,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_data_explorer') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_data_explorer_id,
    practitioner_code,
    license_certificate_document_code,
    examination_assessment_result_code,
    conduct_violation_code,
    full_nm,
    birth_dt,
    age,
    nationality_nm,
    identification_nbr,
    identification_tp_code,
    education_level_nm,
    practice_status_code,
    practice_status_nm,
    certificate_nbr,
    certificate_tp_code,
    certificate_tp_nm,
    issue_dt,
    current_organization_nm,
    concurrent_employment_indicator,
    insufficient_training_indicator,
    no_practice_3_years_indicator,
    exam_assessment_nm,
    exam_examination_period,
    exam_examination_start_dt,
    exam_examination_end_dt,
    exam_overall_result_nm,
    violation_decision_nbr,
    violation_decision_signed_dt,
    violation_note,
    src_stm_code

FROM src
