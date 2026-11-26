/*
*--------------------------------------------------------------------*
* Program code: vp_fct_share_auction_result_snpst_flat
* Program name: VP Fct Share Auction Result Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-05
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-05      huy.pham        [MOI] Flat table ClickHouse: Fact Share Auction
*                                 Result Snapshot x Calendar Date Dim.
*                                 Grain = 1 dong / rpt_code / thang bao cao /
*                                 src_stm_code. snpst_dt_dim_id = LAST_DAY
*                                 (rpt_year, rpt_month). CAST tuong minh cho
*                                 tung cot de khop kieu CK DDL.
* 2026-11-17      claude          [O_VP_83] Them 3 cot KL: registered_share_
*                                 quantity, domestic_winning_share_quantity,
*                                 foreign_winning_share_quantity.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_SHARE_AUCTION_RESULT_SNPST
    CAST(f.share_auction_result_snpst_id    AS string)          AS share_auction_result_snpst_id,
    CAST(f.snpst_dt_dim_id                  AS string)          AS snpst_dt_dim_id,
    CAST(f.rpt_code                         AS string)          AS rpt_code,
    CAST(f.row_nbr                          AS int)             AS row_nbr,
    CAST(f.auction_tp_nm                    AS string)          AS auction_tp_nm,
    CAST(f.auction_tp_group_nm              AS string)          AS auction_tp_group_nm,
    CAST(f.domestic_winning_val             AS decimal(23, 2))  AS domestic_winning_val,
    CAST(f.foreign_winning_val              AS decimal(23, 2))  AS foreign_winning_val,
    CAST(f.registered_share_quantity        AS bigint)          AS registered_share_quantity,
    CAST(f.domestic_winning_share_quantity  AS bigint)          AS domestic_winning_share_quantity,
    CAST(f.foreign_winning_share_quantity   AS bigint)          AS foreign_winning_share_quantity,
    CAST(f.src_stm_code                     AS string)          AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)       AS cdr_dt,
    CAST(cal.year                               AS bigint)      AS year,
    CAST(cal.quarter                            AS bigint)      AS quarter,
    CAST(cal.month                              AS bigint)      AS month,
    CAST(cal.day_of_week                        AS bigint)      AS day_of_week,
    CAST(cal.is_weekend                         AS string)      AS is_weekend,
    CAST(cal.holiday_flag                       AS string)      AS holiday_flag,
    CAST(cal.is_trading_date                    AS string)      AS is_trading_date

FROM {{ ref('dtm_fct_share_auction_result_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
