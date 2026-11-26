/*
*--------------------------------------------------------------------*
* Program code: vp_fct_derivatives_account_snpst_flat
* Program name: VP Fct Derivatives Account Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-07
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-07      huy.pham        [MOI] Flat table ClickHouse: Fact Derivatives Account
*                                 Snapshot x Calendar Date Dim.
*                                 Grain = 1 dong bieu mau (row_nbr) / thang bao cao.
*                                 snpst_dt_dim_id = etl_date (partition ky thuat).
*                                 cdr_dt_dim_id = LAST_DAY(rpt_year, rpt_month).
*                                 JOIN cal theo cdr_dt_dim_id (ngay cuoi thang bao cao).
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_DERIVATIVES_ACCOUNT_SNPST
    CAST(f.derivatives_account_snpst_id    AS string)   AS derivatives_account_snpst_id,
    CAST(f.snpst_dt_dim_id                 AS string)   AS snpst_dt_dim_id,
    CAST(f.cdr_dt_dim_id                   AS string)   AS cdr_dt_dim_id,
    CAST(f.row_nbr                         AS int)      AS row_nbr,
    CAST(f.total_account_quantity          AS int)      AS total_account_quantity,
    CAST(f.domestic_account_quantity       AS int)      AS domestic_account_quantity,
    CAST(f.foreign_account_quantity        AS int)      AS foreign_account_quantity,
    CAST(f.src_stm_code                    AS string)   AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION (theo ngay cuoi thang bao cao)
    CAST(to_date(f.cdr_dt_dim_id, 'yyyyMMdd') AS date)  AS cdr_dt,
    CAST(cal.year                          AS bigint)   AS year,
    CAST(cal.quarter                       AS bigint)   AS quarter,
    CAST(cal.month                         AS bigint)   AS month,
    CAST(cal.day_of_week                   AS bigint)   AS day_of_week,
    CAST(cal.is_weekend                    AS string)   AS is_weekend,
    CAST(cal.holiday_flag                  AS string)   AS holiday_flag,
    CAST(cal.is_trading_date               AS string)   AS is_trading_date

FROM {{ ref('dtm_fct_derivatives_account_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.cdr_dt_dim_id
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
