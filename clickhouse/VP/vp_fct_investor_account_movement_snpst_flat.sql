/*
*--------------------------------------------------------------------*
* Program code: vp_fct_investor_account_movement_snpst_flat
* Program name: VP Fct Investor Account Movement Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-03
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-03      huy.pham        [MOI] Flat table ClickHouse: Fact Investor Account Movement
*                                 Snapshot x Calendar Date Dim.
*                                 Grain = 1 ngay phat sinh / investor_tp_code.
*                                 Loc theo snpst_dt_dim_id = etl_date (ck_snapshot strategy).
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_INVESTOR_ACCOUNT_MOVEMENT_SNPST
    CAST(f.investor_account_movement_snpst_id  AS string)           AS investor_account_movement_snpst_id,
    CAST(f.snpst_dt_dim_id                     AS string)           AS snpst_dt_dim_id,
    CAST(f.investor_tp_code                    AS string)           AS investor_tp_code,
    CAST(f.open_account_count                  AS int)              AS open_account_count,
    CAST(f.close_account_count                 AS int)              AS close_account_count,

    -- From: CALENDAR DATE DIMENSION
    CAST(cal.cdr_dt                            AS date)             AS cdr_dt,
    CAST(cal.year                              AS bigint)           AS year,
    CAST(cal.quarter                           AS bigint)           AS quarter,
    CAST(cal.month                             AS bigint)           AS month,
    CAST(cal.day_of_week                       AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                        AS string)           AS is_weekend,
    CAST(cal.holiday_flag                      AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                   AS string)           AS is_trading_date,
    CAST(cal.cdr_dt                            AS date)             AS ds_snpst_dt

FROM {{ ref('dtm_fct_investor_account_movement_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
