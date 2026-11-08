/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_data_explorer
* Program name: Dtm Opr Practitioner Data Explorer
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		claude				Đồng bộ LLD 2026-11-02: practice_status_code/nm dẫn xuất từ practice_status_code của dim
*                                       + báo cáo tổ chức mới nhất tại etl_date, ELSE '9'; thêm 3 cột indicator (O_NHNCK_35).
* 2026-11-03		claude				Bãi bỏ model theo LLD 2026-11-03 (O_NHNCK_43..46).
* 2026-11-07		claude				Khôi phục + viết lại theo LLD 2026-11-07 (Nhóm 13, commit 02ccedba). Driving đổi sang
*                                       dtm_opr_practitioner_360_profile (1 dòng/NHN, kể cả NHN chưa có CCHN); các thuộc tính NHN
*                                       đọc trực tiếp từ 360 Profile (không tính lại practice_status). LEFT JOIN
*                                       certificate_hist / exam_hist / violation_hist theo practitioner_code
*                                       -> grain NHN x CCHN x lần thi x vi phạm (fan-out chấp nhận, K_NHNCK_74 đếm DISTINCT).
*                                       current_organization_nm: báo cáo tổ chức đang mở (termination_dt IS NULL) có hire_dt mới nhất.
*                                       3 cột indicator đọc dtm_fct_practitioner_daily_snpst tại snapshot etl_date
*                                       (snpst_dt_dim_id = yyyyMMdd của etl_date, cùng quy ước với fact đó thay cho subquery
*                                       cdr_dt_dim của LLD). PK = hash(practitioner_code, cert, exam, violation, src_stm_code) (O_NHNCK_47).
*--------------------------------------------------------------------*
*/

WITH practitioner_profile AS (
    SELECT
        practitioner_code,
        full_nm,
        birth_dt,
        age,
        nationality_nm,
        identification_nbr,
        identification_tp_code,
        education_level_nm,
        practice_status_code,
        practice_status_nm,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_360_profile') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

certificate_hist AS (
    SELECT
        practitioner_code,
        license_certificate_document_code,
        certificate_nbr,
        certificate_tp_code,
        certificate_tp_nm,
        issue_dt
    FROM {{ ref('dtm_opr_practitioner_certificate_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

exam_hist AS (
    SELECT
        practitioner_code,
        examination_assessment_result_code,
        assessment_nm,
        examination_period,
        examination_start_dt,
        examination_end_dt,
        overall_result_nm
    FROM {{ ref('dtm_opr_practitioner_exam_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

violation_hist AS (
    SELECT
        practitioner_code,
        conduct_violation_code,
        decision_nbr,
        decision_signed_dt,
        note
    FROM {{ ref('dtm_opr_practitioner_violation_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

current_employment AS (
    -- Báo cáo tổ chức đang mở (termination_dt IS NULL), hire_dt mới nhất mỗi NHN
    SELECT
        practitioner_code,
        securities_organization_reference_nm
    FROM (
        SELECT
            practitioner_code,
            securities_organization_reference_nm,
            ROW_NUMBER() OVER (
                PARTITION BY practitioner_code
                ORDER BY hire_dt DESC NULLS LAST,
                    organization_employment_rpt_code DESC
            ) AS rn
        FROM {{ ref('dtm_opr_practitioner_employment_hist') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND termination_dt IS NULL
    ) t
    WHERE rn = 1
),

practitioner_dim AS (
    SELECT
        practitioner_code,
        securities_practitioner_dim_id
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

daily_snapshot AS (
    -- Fact snapshot append: chỉ lấy partition của etl_date
    SELECT
        practitioner_dim_id,
        concurrent_employment_indicator,
        insufficient_training_indicator,
        no_practice_3_years_indicator
    FROM {{ ref('dtm_fct_practitioner_daily_snpst') }}
    WHERE snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
)

SELECT
    CAST({{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "concat_ws('-', practitioner_profile.practitioner_code, COALESCE(certificate_hist.license_certificate_document_code, ''), COALESCE(exam_hist.examination_assessment_result_code, ''), COALESCE(violation_hist.conduct_violation_code, ''), practitioner_profile.src_stm_code)") }} AS string) AS practitioner_data_explorer_id,
    CAST(practitioner_profile.practitioner_code AS string)                       AS practitioner_code,
    CAST(certificate_hist.license_certificate_document_code AS string)           AS license_certificate_document_code,
    CAST(exam_hist.examination_assessment_result_code AS string)                 AS examination_assessment_result_code,
    CAST(violation_hist.conduct_violation_code AS string)                        AS conduct_violation_code,
    CAST(practitioner_profile.full_nm AS string)                                 AS full_nm,
    CAST(practitioner_profile.birth_dt AS date)                                  AS birth_dt,
    CAST(practitioner_profile.age AS int)                                        AS age,
    CAST(practitioner_profile.nationality_nm AS string)                          AS nationality_nm,
    CAST(practitioner_profile.identification_nbr AS string)                      AS identification_nbr,
    CAST(practitioner_profile.identification_tp_code AS string)                  AS identification_tp_code,
    CAST(practitioner_profile.education_level_nm AS string)                      AS education_level_nm,
    CAST(practitioner_profile.practice_status_code AS string)                    AS practice_status_code,
    CAST(practitioner_profile.practice_status_nm AS string)                      AS practice_status_nm,
    CAST(certificate_hist.certificate_nbr AS string)                             AS certificate_nbr,
    CAST(certificate_hist.certificate_tp_code AS string)                         AS certificate_tp_code,
    CAST(certificate_hist.certificate_tp_nm AS string)                           AS certificate_tp_nm,
    CAST(certificate_hist.issue_dt AS date)                                      AS issue_dt,
    CAST(current_employment.securities_organization_reference_nm AS string)      AS current_organization_nm,
    CAST(daily_snapshot.concurrent_employment_indicator AS string)               AS concurrent_employment_indicator,
    CAST(daily_snapshot.insufficient_training_indicator AS string)               AS insufficient_training_indicator,
    CAST(daily_snapshot.no_practice_3_years_indicator AS string)                 AS no_practice_3_years_indicator,
    CAST(exam_hist.assessment_nm AS string)                                      AS exam_assessment_nm,
    CAST(exam_hist.examination_period AS string)                                 AS exam_examination_period,
    CAST(exam_hist.examination_start_dt AS date)                                 AS exam_examination_start_dt,
    CAST(exam_hist.examination_end_dt AS date)                                   AS exam_examination_end_dt,
    CAST(exam_hist.overall_result_nm AS string)                                  AS exam_overall_result_nm,
    CAST(violation_hist.decision_nbr AS string)                                  AS violation_decision_nbr,
    CAST(violation_hist.decision_signed_dt AS date)                              AS violation_decision_signed_dt,
    CAST(violation_hist.note AS string)                                          AS violation_note,
    CAST(practitioner_profile.src_stm_code AS string)                            AS src_stm_code
FROM practitioner_profile
LEFT JOIN certificate_hist
    ON certificate_hist.practitioner_code = practitioner_profile.practitioner_code
LEFT JOIN exam_hist
    ON exam_hist.practitioner_code = practitioner_profile.practitioner_code
LEFT JOIN violation_hist
    ON violation_hist.practitioner_code = practitioner_profile.practitioner_code
LEFT JOIN current_employment
    ON current_employment.practitioner_code = practitioner_profile.practitioner_code
LEFT JOIN practitioner_dim
    ON practitioner_dim.practitioner_code = practitioner_profile.practitioner_code
LEFT JOIN daily_snapshot
    ON daily_snapshot.practitioner_dim_id = practitioner_dim.securities_practitioner_dim_id
