/*
*--------------------------------------------------------------------*
* Program code: atm_member_rating
* Program name: Atomic Member Rating
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khoi tao theo LLD Atomic FMS UAT 20261006 (lld_FMS_RANK.yaml)
*										Dung member_rating_period_id/code (LLD ghi m_ember_* - loi chinh ta, da bao Data Modeler);
*										rating_period_tp_code giu gia tri raw RANK_TYPE (LLD "ETL map" chua co bang map)
*--------------------------------------------------------------------*
*/

WITH ra AS (
    SELECT
        id
        , sec_id
        , rt_pd_id
        , total_score
        , rank_index
        , rank_type
    FROM {{ ref('ods_fms_rank') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_RANK', "ra.id") }}               AS member_rating_id
    , CAST(ra.id AS string)                                                AS member_rating_code
    , CAST('FMS_RANK' AS string)                                             AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "ra.sec_id") }}   AS fmc_id
    , CAST(ra.sec_id AS string)                                            AS fmc_code
    , {{ generate_surrogate_key_bigint('FMS_RATING_PD', "ra.rt_pd_id") }}  AS member_rating_period_id
    , CAST(ra.rt_pd_id AS string)                                          AS member_rating_period_code
    , CAST(ra.total_score AS int)                                          AS total_score_amt
    , CAST(ra.rank_index AS int)                                           AS rank_index
    , CAST(ra.rank_type AS string)                                         AS rating_period_tp_code
FROM ra