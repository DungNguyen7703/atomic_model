/*
*--------------------------------------------------------------------*
* Program code: vp_fct_government_bond_bidding_result_snpst_flat
* Program name: VP Fct Government Bond Bidding Result Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-03
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-03      huy.pham        [MOI] Flat table ClickHouse: Fact Government Bond Bidding
*                                 Result Snapshot x Calendar Date Dim.
*                                 Grain = 1 dong ket qua dau thau TPCP.
*                                 snpst_dt_dim_id = etl_date (partition ky thuat).
*                                 cdr_dt_dim_id = issue_dt (ngay phat hanh, JOIN cal).
*                                 KHONG loc etl_date — nap TOAN BO lich su moi lan ETL.
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
* 2026-11-07      huy.pham        [SUA] Them cdr_dt_dim_id. JOIN cal theo cdr_dt_dim_id
*                                 (issue_dt) thay vi snpst_dt_dim_id. Bo AND ds_snpst_dt.
* 2026-11-09      huy.pham        [SUA, TKNB Nhom 5 HNX06] Them calling_val, rpt_year,
*                                 rpt_month, government_bond_term_dim_id.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_GOVERNMENT_BOND_BIDDING_RESULT_SNPST
    CAST(f.government_bond_bidding_result_snpst_id  AS string)           AS government_bond_bidding_result_snpst_id,
    CAST(f.snpst_dt_dim_id                          AS string)           AS snpst_dt_dim_id,
    CAST(f.cdr_dt_dim_id                            AS string)           AS cdr_dt_dim_id,
    CAST(f.bidding_session                          AS string)           AS bidding_session,
    CAST(f.bond_code                                AS string)           AS bond_code,
    CAST(f.bond_term                                AS string)           AS bond_term,
    CAST(f.issue_term_years                         AS decimal(10,4))    AS issue_term_years,
    CAST(f.winning_val                              AS decimal(23,2))    AS winning_val,
    CAST(f.winning_interest_rate                    AS decimal(5,2))     AS winning_interest_rate,
    CAST(f.calling_val                              AS decimal(23,2))    AS calling_val,
    CAST(f.rpt_year                                 AS int)              AS rpt_year,
    CAST(f.rpt_month                                AS int)              AS rpt_month,
    CAST(f.government_bond_term_dim_id              AS string)           AS government_bond_term_dim_id,
    CAST(f.src_stm_code                             AS string)           AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION (theo ngay phat hanh TPCP)
    CAST(to_date(f.cdr_dt_dim_id, 'yyyyMMdd')       AS date)             AS cdr_dt,
    CAST(cal.year                                   AS bigint)           AS year,
    CAST(cal.quarter                                AS bigint)           AS quarter,
    CAST(cal.month                                  AS bigint)           AS month,
    CAST(cal.day_of_week                            AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                             AS string)           AS is_weekend,
    CAST(cal.holiday_flag                           AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                        AS string)           AS is_trading_date

FROM {{ ref('dtm_fct_government_bond_bidding_result_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.cdr_dt_dim_id
    --where snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
