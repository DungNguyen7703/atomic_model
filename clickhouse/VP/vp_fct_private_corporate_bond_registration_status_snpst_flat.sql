/*
*--------------------------------------------------------------------*
* Program code: vp_fct_private_corporate_bond_registration_status_snpst_flat
* Program name: VP Fct Private Corporate Bond Registration Status Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-08
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-18      claude          [O_VP_86] Them par_val.
* 2026-11-08      huy.pham        [MOI, O_VP_71] Flat table ClickHouse: Fact Private
*                                 Corporate Bond Registration Status Snapshot x Calendar
*                                 Date Dim. Grain = 1 ma TP / 1 trang thai / 1 thang
*                                 bao cao HNX. So lieu luy ke tu dau nam.
*                                 snpst_dt_dim_id = etl_date (partition ky thuat, loc).
*                                 cdr_dt_dim_id = LAST_DAY(rpt_year, rpt_month)
*                                 (ngay nghiep vu) → JOIN cal → cdr_dt.
*                                 ck_event: DELETE cdr_dt = etl_date, INSERT thang do.
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_PRIVATE_CORPORATE_BOND_REGISTRATION_STATUS_SNPST
    CAST(f.private_corporate_bond_registration_status_snpst_id  AS string)   AS private_corporate_bond_registration_status_snpst_id,
    CAST(f.snpst_dt_dim_id                                      AS string)   AS snpst_dt_dim_id,
    CAST(f.cdr_dt_dim_id                                        AS string)   AS cdr_dt_dim_id,
    CAST(f.bond_code                                            AS string)   AS bond_code,
    CAST(f.trading_registration_status_nm                       AS string)   AS trading_registration_status_nm,
    CAST(f.registered_trading_bond_quantity                     AS bigint)   AS registered_trading_bond_quantity,
    CAST(f.src_stm_code                                         AS string)   AS src_stm_code,
    CAST(f.par_val                                              AS bigint)   AS par_val,

    -- From: CALENDAR DATE DIMENSION (theo LAST_DAY thang bao cao)
    CAST(to_date(f.cdr_dt_dim_id, 'yyyyMMdd')                   AS date)     AS cdr_dt,
    CAST(cal.year                                               AS bigint)   AS year,
    CAST(cal.quarter                                            AS bigint)   AS quarter,
    CAST(cal.month                                              AS bigint)   AS month,
    CAST(cal.day_of_week                                        AS bigint)   AS day_of_week,
    CAST(cal.is_weekend                                         AS string)   AS is_weekend,
    CAST(cal.holiday_flag                                       AS string)   AS holiday_flag,
    CAST(cal.is_trading_date                                    AS string)   AS is_trading_date

FROM {{ ref('dtm_fct_private_corporate_bond_registration_status_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.cdr_dt_dim_id
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
