/*
*--------------------------------------------------------------------*
* Program code: vp_fct_private_corporate_bond_registration_snpst_flat
* Program name: VP Fct Private Corporate Bond Registration Snapshot Flat
* Created by: huy.pham
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-30      huy.pham        [MOI] Flat table ClickHouse: Fact Private Corporate
*                                 Bond Registration Snapshot x Calendar Date Dim.
*                                 Grain = 1 ma TP / thang bao cao / src_stm_code.
*                                 snpst_dt_dim_id = LAST_DAY(rpt_year, rpt_month).
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_PRIVATE_CORPORATE_BOND_REGISTRATION_SNPST
    CAST(f.private_corporate_bond_registration_snpst_id    AS string)   AS private_corporate_bond_registration_snpst_id,
    CAST(f.snpst_dt_dim_id                                 AS string)   AS snpst_dt_dim_id,
    CAST(f.bond_code                                       AS string)   AS bond_code,
    CAST(f.rpt_year                                        AS string)   AS rpt_year,
    CAST(f.rpt_month                                       AS string)   AS rpt_month,
    CAST(f.maturity_dt                                     AS date)     AS maturity_dt,
    CAST(f.src_stm_code                                    AS string)   AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)               AS cdr_dt,
    CAST(cal.year                               AS bigint)              AS year,
    CAST(cal.quarter                            AS bigint)              AS quarter,
    CAST(cal.month                              AS bigint)              AS month,
    CAST(cal.day_of_week                        AS bigint)              AS day_of_week,
    CAST(cal.is_weekend                         AS string)              AS is_weekend,
    CAST(cal.holiday_flag                       AS string)              AS holiday_flag,
    CAST(cal.is_trading_date                    AS string)              AS is_trading_date

FROM {{ ref('dtm_fct_private_corporate_bond_registration_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
