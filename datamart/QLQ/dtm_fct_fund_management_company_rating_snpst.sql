/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_fund_management_company_rating_snpst
* Program name: Dtm Fct Fund Management Company Rating Snpst
* Created by:
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-11		claude (sync)		Tạo mới theo LLD commit 56eb71c6 (O_QLQ_88): xếp loại (RANK_TYPE) + tổng điểm CAMEL theo kỳ đánh giá
*                                       bán niên/năm. Grain = 1 CTQLQ × 1 kỳ (PK hash fmc_id, rpt_year, rating_period_code, src_stm_code).
*                                       Mỗi kỳ giữ 1 dòng: ROW_NUMBER theo rating_finalized_flag DESC, total_score_amt DESC, member_rating_code DESC = 1.
*                                       snpst_dt_dim_id = ngày cuối kỳ (30/06 khi period = '1', 31/12 còn lại), KHÔNG phải etl_date;
*                                       nạp ĐỦ mọi kỳ (không khóa :etl_date) — cùng cơ chế partition overwrite như
*                                       dtm_fct_fund_management_company_snpst (xem rủi ro R1/R2 trong file đó).
*--------------------------------------------------------------------*
*/

WITH member_rating_period AS (
    SELECT
        member_rating_period_id,
        rpt_year,
        rating_period_tp_code,
        rating_finalized_flag
    FROM {{ ref('atm_member_rating_period') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RATING_PD'
),

member_rating AS (
    SELECT
        member_rating_period_id,
        member_rating_code,
        fmc_id,
        rating_period_tp_code,
        total_score_amt,
        src_stm_code
    FROM {{ ref('atm_member_rating') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RANK'
),

rating_ranked AS (
    SELECT
        member_rating.fmc_id,
        member_rating.member_rating_code,
        member_rating.rating_period_tp_code                                               AS rating_class_code,
        member_rating.total_score_amt,
        member_rating.src_stm_code,
        member_rating_period.rpt_year,
        member_rating_period.rating_period_tp_code                                        AS rating_period_code,
        member_rating_period.rating_finalized_flag,
        CASE member_rating_period.rating_period_tp_code
            WHEN '1' THEN MAKE_DATE(member_rating_period.rpt_year, 6, 30)
            ELSE MAKE_DATE(member_rating_period.rpt_year, 12, 31)
        END                                                                               AS rating_period_end_dt,
        ROW_NUMBER() OVER (
            PARTITION BY member_rating.fmc_id, member_rating_period.rpt_year, member_rating_period.rating_period_tp_code
            ORDER BY member_rating_period.rating_finalized_flag DESC,
                     member_rating.total_score_amt DESC,
                     member_rating.member_rating_code DESC
        )                                                                                 AS rn_rating
    FROM member_rating
    INNER JOIN member_rating_period
        ON member_rating_period.member_rating_period_id = member_rating.member_rating_period_id
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FMS_RANK', "concat_ws('|', fmc_id, rpt_year, rating_period_code, src_stm_code)") }} AS string)
                                                                             AS fund_management_company_rating_snpst_id,
    date_format(rating_period_end_dt, 'yyyyMMdd')                            AS snpst_dt_dim_id,
    CAST(fmc_id AS string)                                                   AS fmc_id,
    CAST(member_rating_code AS string)                                       AS member_rating_code,
    CAST(rpt_year AS int)                                                    AS rpt_year,
    CAST(rating_period_code AS string)                                       AS rating_period_code,
    CAST(rating_period_end_dt AS date)                                       AS rating_period_end_dt,
    CAST(rating_class_code AS string)                                        AS rating_class_code,
    CAST(total_score_amt AS int)                                             AS total_score_amt,
    CAST(rating_finalized_flag AS int)                                       AS rating_finalized_flag,
    CAST(src_stm_code AS string)                                             AS src_stm_code
FROM rating_ranked
WHERE rn_rating = 1
