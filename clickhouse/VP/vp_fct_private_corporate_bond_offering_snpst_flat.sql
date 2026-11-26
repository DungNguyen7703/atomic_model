/*
*--------------------------------------------------------------------*
* Program code: vp_fct_private_corporate_bond_offering_snpst_flat
* Program name: VP Fct Private Corporate Bond Offering Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-11      huy.pham        [MOI, O_VP_76] Flat table ClickHouse: Fact Private
*                                 Corporate Bond Offering Snapshot x Calendar Date Dim.
*                                 Grain = 1 ma TPDNRL x 1 thi truong x 1 ngay dang tin
*                                 x 1 thang bao cao HNX (BM 27/28).
*                                 snpst_dt_dim_id = FK toi cdr_dt_dim = LAST_DAY(rpt_year,
*                                 rpt_month). CAST tuong minh cho tung cot de khop DDL.
* 2026-11-17      claude          [O_VP_83] Them 5 cot: enterprise_tp, business_sector,
*                                 convertible_bond_ind, warrant_linked_bond_ind,
*                                 secured_bond_ind.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_PRIVATE_CORPORATE_BOND_OFFERING_SNPST
    CAST(f.private_corporate_bond_offering_snpst_id AS string)           AS private_corporate_bond_offering_snpst_id,
    CAST(f.bond_code                                AS string)           AS bond_code,
    CAST(f.market_tp                                AS string)           AS market_tp,
    CAST(f.posting_dt                               AS date)             AS posting_dt,
    CAST(f.issue_dt                                 AS date)             AS issue_dt,
    CAST(f.offering_bond_quantity                   AS bigint)           AS offering_bond_quantity,
    CAST(f.par_val                                  AS decimal(23,2))    AS par_val,
    CAST(f.offering_val_amt                         AS decimal(23,2))    AS offering_val_amt,
    CAST(f.rpt_year                                 AS int)              AS rpt_year,
    CAST(f.rpt_month                                AS int)              AS rpt_month,
    CAST(f.rpt_day                                  AS int)              AS rpt_day,
    CAST(f.bond_term_years                          AS decimal(10,4))    AS bond_term_years,
    CAST(f.issue_interest_rate                      AS decimal(5,2))     AS issue_interest_rate,
    CAST(f.src_stm_code                             AS string)           AS src_stm_code,
    CAST(f.enterprise_tp                            AS string)           AS enterprise_tp,
    CAST(f.business_sector                            AS string)           AS business_sector,
    CAST(f.convertible_bond_ind                       AS int)              AS convertible_bond_ind,
    CAST(f.warrant_linked_bond_ind                    AS int)              AS warrant_linked_bond_ind,
    CAST(f.secured_bond_ind                           AS int)              AS secured_bond_ind,

    -- From: CALENDAR DATE DIMENSION (theo ngay cuoi thang bao cao)
    CAST(to_date(f.cdr_dt_dim_id, 'yyyyMMdd')        AS date)             AS cdr_dt,
    CAST(cal.year                                   AS bigint)           AS year,
    CAST(cal.quarter                                AS bigint)           AS quarter,
    CAST(cal.month                                  AS bigint)           AS month,
    CAST(cal.day_of_week                            AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                             AS string)           AS is_weekend,
    CAST(cal.holiday_flag                           AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                        AS string)           AS is_trading_date

FROM {{ ref('dtm_fct_private_corporate_bond_offering_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.cdr_dt_dim_id
