/*
*--------------------------------------------------------------------*
* Program code: vp_fct_government_bond_listing_snpst_flat
* Program name: VP Fct Government Bond Listing Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-06      huy.pham        [MOI] Flat table ClickHouse: Fact Government Bond
*                                 Listing Snapshot x Calendar Date Dim.
*                                 Grain = 1 ma TPCP x 1 thang bao cao HNX.
*                                 snpst_dt_dim_id = etl_date (partition).
*                                 cdr_dt_dim_id = LAST_DAY thang bao cao -> JOIN cal.
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_GOVERNMENT_BOND_LISTING_SNPST
    CAST(f.government_bond_listing_snpst_id    AS string)           AS government_bond_listing_snpst_id,
    CAST(f.snpst_dt_dim_id                     AS string)           AS snpst_dt_dim_id,
    CAST(f.cdr_dt_dim_id                       AS string)           AS cdr_dt_dim_id,
    CAST(f.bond_code                           AS string)           AS bond_code,
    CAST(f.rpt_year                            AS int)              AS rpt_year,
    CAST(f.rpt_month                           AS int)              AS rpt_month,
    CAST(f.listed_bond_quantity                AS bigint)           AS listed_bond_quantity,
    CAST(f.listed_bond_val                     AS decimal(23,2))    AS listed_bond_val,
    CAST(f.src_stm_code                        AS string)           AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION (theo ngay cuoi thang bao cao)
    CAST(to_date(f.cdr_dt_dim_id, 'yyyyMMdd')  AS date)            AS cdr_dt,
    CAST(cal.year                              AS bigint)           AS year,
    CAST(cal.quarter                           AS bigint)           AS quarter,
    CAST(cal.month                             AS bigint)           AS month,
    CAST(cal.day_of_week                       AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                        AS string)           AS is_weekend,
    CAST(cal.holiday_flag                      AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                   AS string)           AS is_trading_date

FROM {{ ref('dtm_fct_government_bond_listing_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.cdr_dt_dim_id
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
