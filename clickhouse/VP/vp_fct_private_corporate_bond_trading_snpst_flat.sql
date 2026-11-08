/*
*--------------------------------------------------------------------*
* Program code: vp_fct_private_corporate_bond_trading_snpst_flat
* Program name: VP Fct Private Corporate Bond Trading Snapshot Flat
* Created by: huy.pham
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-30      huy.pham        [MOI] Flat table ClickHouse: Fact Private Corporate
*                                 Bond Trading Snapshot x Calendar Date Dim.
*                                 Grain = 1 dong / ngay bao cao / src_stm_code.
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_PRIVATE_CORPORATE_BOND_TRADING_SNPST
    CAST(f.private_corporate_bond_trading_snpst_id  AS string)           AS private_corporate_bond_trading_snpst_id,
    CAST(f.snpst_dt_dim_id                          AS string)           AS snpst_dt_dim_id,
    CAST(f.trading_val                              AS decimal(23,2))    AS trading_val,
    CAST(f.foreign_buy_val                          AS decimal(23,2))    AS foreign_buy_val,
    CAST(f.foreign_sell_val                         AS decimal(23,2))    AS foreign_sell_val,
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

FROM {{ ref('dtm_fct_private_corporate_bond_trading_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
