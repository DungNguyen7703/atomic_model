/*
*--------------------------------------------------------------------*
* Program code: dtm_ 
* Program name: Dtm Fct Public Company Compliance Evaluation Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH company AS (
    SELECT
        public_company_dim_id,
        public_company_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

evaluation AS (
    SELECT
        pc_code,
        pc_evaluation_id,
        pc_evaluation_code,
        pc_evaluation_period_id,
        evaluation_dt
    FROM {{ ref('atm_pc_evaluation') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATIONS'
),

evaluation_period AS (
    SELECT
        pc_evaluation_period_id,
        evaluation_year,
        evaluation_month
    FROM {{ ref('atm_pc_evaluation_period') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATION_PERIODS'
),

evaluation_detail AS (
    SELECT
        evaluation_score,
        evaluation_result_text,
        evaluation_level_code,
        pc_evaluation_id,
        pc_evaluation_criterion_id
    FROM {{ ref('atm_pc_evaluation_detail') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATION_DETAILS'
),

evaluation_level AS (
    SELECT
        cl_code,
        cl_nm
    FROM {{ source('source_atm', 'raw_classification_value') }}
    WHERE schema_code = 'PUBLIC_COMPANY_EVALUATION_DETAIL_LEVEL'
),

-- Giữ score + ghép mức độ đánh giá với kết quả theo format "<Mức độ>: <Kết quả>" trước khi pivot
evaluation_detail_enriched AS (
    SELECT
        evaluation_detail.pc_evaluation_id,
        evaluation_detail.pc_evaluation_criterion_id,
        evaluation_detail.evaluation_score,
        NULLIF(concat_ws(': ', evaluation_level.cl_nm, NULLIF(trim(evaluation_detail.evaluation_result_text), '')), '') AS assessment_text
    FROM evaluation_detail
    LEFT JOIN evaluation_level
        ON evaluation_level.cl_code = evaluation_detail.evaluation_level_code
),

evaluation_criterion AS (
    SELECT
        pc_evaluation_criterion_id,
        pc_evaluation_group_id,
        pc_evaluation_criterion_code
    FROM {{ ref('atm_pc_evaluation_criterion') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATION_CRITERIA'
),

evaluation_group AS (
    SELECT
        pc_evaluation_group_id,
        pc_evaluation_group_code
    FROM {{ ref('atm_pc_evaluation_group') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND pc_evaluation_group_code = 'TUAN_THU'
        AND src_stm_code = 'IDS_EVALUATION_GROUPS'
),

-- Mỗi công ty × kỳ chỉ giữ lượt chấm mới nhất tính đến etl_date (kỳ bị chấm lại thì lấy lần chấm sau cùng)
-- Trùng ngày chấm thì lấy id nguồn lớn nhất (pc_evaluation_id là hash nên không dùng để sắp xếp)
evaluation_latest AS (
    SELECT
        pc_code,
        pc_evaluation_id,
        pc_evaluation_period_id,
        evaluation_dt
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY pc_code, pc_evaluation_period_id
                ORDER BY evaluation_dt DESC,
                         CAST(pc_evaluation_code AS bigint) DESC
            ) AS rn
        FROM evaluation
        WHERE evaluation_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    ) evaluation_ranked
    WHERE rn = 1
)

SELECT
    CAST(company.public_company_dim_id AS string)                                                   AS public_company_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')                          AS snpst_dt_dim_id,
    CAST(date_format(evaluation_latest.evaluation_dt, 'yyyyMMdd') AS string)                        AS evaluation_dt_dim_id,
    CAST(evaluation_period.evaluation_year AS string)                                               AS evaluation_year,
    CAST(evaluation_period.evaluation_month AS string)                                              AS evaluation_month,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCTC'          THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS disclosure_bctc_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCTC'          THEN evaluation_detail_enriched.assessment_text  END) AS string) AS disclosure_bctc_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCTN'          THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS disclosure_bctn_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCTN'          THEN evaluation_detail_enriched.assessment_text  END) AS string) AS disclosure_bctn_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCTHQT'        THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS disclosure_governance_report_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCTHQT'        THEN evaluation_detail_enriched.assessment_text  END) AS string) AS disclosure_governance_report_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_CBTTBT_TDTGD'  THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS disclosure_ceo_change_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_CBTTBT_TDTGD'  THEN evaluation_detail_enriched.assessment_text  END) AS string) AS disclosure_ceo_change_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_VP_UBCK'       THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS violation_ubck_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_VP_UBCK'       THEN evaluation_detail_enriched.assessment_text  END) AS string) AS violation_ubck_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_CBTTBT_VPVT'   THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS violation_other_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_CBTTBT_VPVT'   THEN evaluation_detail_enriched.assessment_text  END) AS string) AS violation_other_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_DLCT'     THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS charter_regulation_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_DLCT'     THEN evaluation_detail_enriched.assessment_text  END) AS string) AS charter_regulation_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLDHDCD'  THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS annual_meeting_count_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLDHDCD'  THEN evaluation_detail_enriched.assessment_text  END) AS string) AS annual_meeting_count_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLTVDL'   THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS independent_board_member_count_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLTVDL'   THEN evaluation_detail_enriched.assessment_text  END) AS string) AS independent_board_member_count_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLTVKDH'  THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS non_executive_board_member_count_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLTVKDH'  THEN evaluation_detail_enriched.assessment_text  END) AS string) AS non_executive_board_member_count_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_TCTV'     THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS board_member_qualification_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_TCTV'     THEN evaluation_detail_enriched.assessment_text  END) AS string) AS board_member_qualification_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLTVBKS'  THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS supervisory_board_count_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_QTCT_SLTVBKS'  THEN evaluation_detail_enriched.assessment_text  END) AS string) AS supervisory_board_count_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCSDV_BCTDSDV' THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS capital_use_progress_report_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCSDV_BCTDSDV' THEN evaluation_detail_enriched.assessment_text  END) AS string) AS capital_use_progress_report_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCSDV_TDPASDV' THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS capital_use_plan_change_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TUAN_THU_BCSDV_TDPASDV' THEN evaluation_detail_enriched.assessment_text  END) AS string) AS capital_use_plan_change_assessment,
    CAST(SUM(CASE WHEN evaluation_group.pc_evaluation_group_code = 'TUAN_THU'                       THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS total_compliance_score
FROM company
LEFT JOIN evaluation_latest
    ON evaluation_latest.pc_code = company.public_company_code
LEFT JOIN evaluation_period
    ON evaluation_period.pc_evaluation_period_id = evaluation_latest.pc_evaluation_period_id
LEFT JOIN evaluation_detail_enriched
    ON evaluation_detail_enriched.pc_evaluation_id = evaluation_latest.pc_evaluation_id
LEFT JOIN evaluation_criterion
    ON evaluation_criterion.pc_evaluation_criterion_id = evaluation_detail_enriched.pc_evaluation_criterion_id
LEFT JOIN evaluation_group
    ON evaluation_group.pc_evaluation_group_id = evaluation_criterion.pc_evaluation_group_id
GROUP BY company.public_company_dim_id,
         evaluation_latest.evaluation_dt,
         evaluation_period.evaluation_year,
         evaluation_period.evaluation_month
