/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_financial_evaluation_snpst
* Program name: Dtm Fct Public Company Financial Evaluation Snpst
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
        AND pc_evaluation_group_code = 'TAI_CHINH'
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
    CAST(company.public_company_dim_id AS string)                                                     AS public_company_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')                            AS snpst_dt_dim_id,
    CAST(date_format(evaluation_latest.evaluation_dt, 'yyyyMMdd') AS string)                          AS evaluation_dt_dim_id,
    CAST(evaluation_period.evaluation_year AS string)                                                 AS evaluation_year,
    CAST(evaluation_period.evaluation_month AS string)                                                AS evaluation_month,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_YKKT'           THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS audit_opinion_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_YKKT'           THEN evaluation_detail_enriched.assessment_text  END) AS string) AS audit_opinion_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_ROA'            THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS roa_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_ROA'            THEN evaluation_detail_enriched.assessment_text  END) AS string) AS roa_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_DTTHDKD'        THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS operating_cash_flow_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_DTTHDKD'        THEN evaluation_detail_enriched.assessment_text  END) AS string) AS operating_cash_flow_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_KNTTHT'         THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS current_ratio_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_KNTTHT'         THEN evaluation_detail_enriched.assessment_text  END) AS string) AS current_ratio_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_EBIT'           THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS ebit_interest_coverage_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_EBIT'           THEN evaluation_detail_enriched.assessment_text  END) AS string) AS ebit_interest_coverage_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_NO_VON_CSH'     THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS debt_to_equity_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_NO_VON_CSH'     THEN evaluation_detail_enriched.assessment_text  END) AS string) AS debt_to_equity_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_VON_CSH'        THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS equity_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_VON_CSH'        THEN evaluation_detail_enriched.assessment_text  END) AS string) AS equity_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_ROE'            THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS roe_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_ROE'            THEN evaluation_detail_enriched.assessment_text  END) AS string) AS roe_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_DTHDTC_LNST'    THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS financial_revenue_to_profit_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_DTHDTC_LNST'    THEN evaluation_detail_enriched.assessment_text  END) AS string) AS financial_revenue_to_profit_assessment,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_DTHD_KHAC_LNST' THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS other_revenue_to_profit_score,
    CAST(MAX(CASE WHEN evaluation_criterion.pc_evaluation_criterion_code = 'TAI_CHINH_DTHD_KHAC_LNST' THEN evaluation_detail_enriched.assessment_text  END) AS string) AS other_revenue_to_profit_assessment,
    CAST(SUM(CASE WHEN evaluation_group.pc_evaluation_group_code = 'TAI_CHINH'                        THEN evaluation_detail_enriched.evaluation_score END) AS int)    AS total_financial_score
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
