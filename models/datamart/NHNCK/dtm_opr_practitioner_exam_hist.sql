/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_exam_hist
* Program name: Dtm Opr Practitioner Exam Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH exam_assessment_result AS (
    SELECT
        sp_code,
        sp_qualification_examination_assessment_result_code,
        law_score,
        specialization_score,
        law_result_code,
        specialization_result_code,
        overall_result_code,
        src_stm_code,
        sp_qualification_examination_assessment_id
    FROM {{ ref('atm_sp_qualification_examination_assessment_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_EXAM_DETAILS'
),

exam_assessment AS (
    SELECT
        assessment_nm,
        rpt_year,
        examination_session_nbr,
        examination_start_dt,
        examination_end_dt,
        sp_qualification_examination_assessment_id,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_qualification_examination_assessment') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_EXAM_SESSIONS'
),

exam_result_lookup AS (
    SELECT
        cl_nm,
        cl_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
    WHERE schema_code = 'EXAM_RESULT'
),

decision_document AS (
    SELECT
        decision_nbr,
        decision_signed_dt,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_license_decision_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_DECISIONS'
)

SELECT
    CAST(exam_assessment_result.sp_code AS string)                                   AS practitioner_code,
    CAST(exam_assessment_result.sp_qualification_examination_assessment_result_code AS string) AS examination_assessment_result_code,
    CAST(exam_assessment.assessment_nm AS string)                                AS assessment_nm,
    CAST(exam_assessment.rpt_year AS int)                                        AS rpt_year,
    CAST(exam_assessment.examination_session_nbr AS int)                         AS examination_session_nbr,
    CAST(CONCAT(exam_assessment.rpt_year, '_', exam_assessment.examination_session_nbr) AS string) AS examination_period,
    CAST(exam_assessment.examination_start_dt AS date)                           AS examination_start_dt,
    CAST(exam_assessment.examination_end_dt AS date)                             AS examination_end_dt,
    CAST(exam_assessment_result.law_score AS string)                                 AS law_score,
    CAST(exam_assessment_result.specialization_score AS string)                      AS specialization_score,
    CAST(exam_assessment_result.law_result_code AS string)                           AS law_result_code,
    CAST(exam_result_lookup.cl_nm AS string)                                                 AS law_result_nm,
    CAST(exam_assessment_result.specialization_result_code AS string)                AS specialization_result_code,
    CAST(specialization_result_lookup.cl_nm AS string)                                               AS specialization_result_nm,
    CAST(exam_assessment_result.overall_result_code AS string)                       AS overall_result_code,
    CAST(overall_result_lookup.cl_nm AS string)                                               AS overall_result_nm,
    CAST(decision_document.decision_nbr AS string)                                 AS decision_nbr,
    CAST(decision_document.decision_signed_dt AS date)                             AS decision_signed_dt,
    CAST(exam_assessment_result.src_stm_code AS string)                              AS src_stm_code
FROM exam_assessment_result
JOIN exam_assessment
    ON exam_assessment.sp_qualification_examination_assessment_id = exam_assessment_result.sp_qualification_examination_assessment_id
LEFT JOIN exam_result_lookup
    ON exam_result_lookup.cl_code = exam_assessment_result.law_result_code
LEFT JOIN exam_result_lookup AS specialization_result_lookup
    ON specialization_result_lookup.cl_code = exam_assessment_result.specialization_result_code
LEFT JOIN exam_result_lookup AS overall_result_lookup
    ON overall_result_lookup.cl_code = exam_assessment_result.overall_result_code
LEFT JOIN decision_document
    ON decision_document.sp_license_decision_document_id = exam_assessment.sp_license_decision_document_id
