/*
*--------------------------------------------------------------------*
* Program code: vp_fct_listed_equity_snpst_flat
* Program name: VP Fct Listed Equity Snapshot Flat
* Created by: huy.pham
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-30      huy.pham        [MOI] Flat table ClickHouse: Fact Listed Equity
*                                 Snapshot x Calendar Date Dim.
*                                 Grain = 1 ma (stock_tp_code 2/3/6) / ngay GD.
*                                 next_day_vol_weighted_average_price/market_price/
*                                 market_cap_val = NULL cho dong ngay D (chua co D+1).
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_LISTED_EQUITY_SNPST
    CAST(f.listed_equity_snpst_id                   AS string)           AS listed_equity_snpst_id,
    CAST(f.snpst_dt_dim_id                          AS string)           AS snpst_dt_dim_id,
    CAST(f.ticker_symbol                            AS string)           AS ticker_symbol,
    CAST(f.floor_code                               AS string)           AS floor_code,
    CAST(f.stock_tp_code                            AS string)           AS stock_tp_code,
    CAST(f.outstanding_share_quantity               AS bigint)           AS outstanding_share_quantity,
    CAST(f.listed_share_quantity                    AS bigint)           AS listed_share_quantity,
    CAST(f.listed_share_val                         AS decimal(23,2))    AS listed_share_val,
    CAST(f.close_price                              AS decimal(23,2))    AS close_price,
    CAST(f.reference_price                          AS decimal(23,2))    AS reference_price,
    CAST(f.next_day_vol_weighted_average_price      AS bigint)           AS next_day_vol_weighted_average_price,
    CAST(f.market_price                             AS decimal(23,2))    AS market_price,
    CAST(f.market_cap_val                           AS decimal(23,2))    AS market_cap_val,
    CAST(f.src_stm_code                             AS string)           AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)                AS cdr_dt,
    CAST(cal.year                               AS bigint)               AS year,
    CAST(cal.quarter                            AS bigint)               AS quarter,
    CAST(cal.month                              AS bigint)               AS month,
    CAST(cal.day_of_week                        AS bigint)               AS day_of_week,
    CAST(cal.is_weekend                         AS string)               AS is_weekend,
    CAST(cal.holiday_flag                       AS string)               AS holiday_flag,
    CAST(cal.is_trading_date                    AS string)               AS is_trading_date

FROM {{ ref('dtm_fct_listed_equity_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
