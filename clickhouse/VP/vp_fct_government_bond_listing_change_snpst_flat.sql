/*
*--------------------------------------------------------------------*
* Program code: vp_fct_government_bond_listing_change_snpst_flat
* Program name: VP Fct Government Bond Listing Change Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-08
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-18      claude          [O_VP_86] Them cot par_val (menh gia TPCP).
* 2026-11-08      huy.pham        [MOI, O_VP_71] Flat table ClickHouse: Fact Government
*                                 Bond Listing Change Snapshot x Calendar Date Dim.
*                                 Grain = 1 su kien thay doi niem yet TPCP / ngay.
*                                 snpst_dt_dim_id = etl_date (partition ky thuat, loc).
*                                 cdr_dt_dim_id = listing_change_dt (ngay nghiep vu).
*                                 JOIN cal theo cdr_dt_dim_id -> cdr_dt.
*                                 ck_event: DELETE cdr_dt = etl_date, INSERT ngay do.
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_GOVERNMENT_BOND_LISTING_CHANGE_SNPST
    CAST(f.government_bond_listing_change_snpst_id  AS string)           AS government_bond_listing_change_snpst_id,
    CAST(f.snpst_dt_dim_id                          AS string)           AS snpst_dt_dim_id,
    CAST(f.cdr_dt_dim_id                            AS string)           AS cdr_dt_dim_id,
    CAST(f.bond_code                                AS string)           AS bond_code,
    CAST(f.listing_status_nm                        AS string)           AS listing_status_nm,
    CAST(f.additional_bond_quantity                 AS bigint)           AS additional_bond_quantity,
    CAST(f.par_val                                  AS bigint)           AS par_val,
    CAST(f.src_stm_code                             AS string)           AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION (theo listing_change_dt)
    CAST(to_date(f.cdr_dt_dim_id, 'yyyyMMdd')       AS date)             AS cdr_dt,
    CAST(cal.year                                   AS bigint)           AS year,
    CAST(cal.quarter                                AS bigint)           AS quarter,
    CAST(cal.month                                  AS bigint)           AS month,
    CAST(cal.day_of_week                            AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                             AS string)           AS is_weekend,
    CAST(cal.holiday_flag                           AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                        AS string)           AS is_trading_date

FROM {{ ref('dtm_fct_government_bond_listing_change_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.cdr_dt_dim_id
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
