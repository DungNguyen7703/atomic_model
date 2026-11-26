/*
*--------------------------------------------------------------------*
* Program code: vp_fct_securities_offering_event_flat
* Program name: VP Fct Securities Offering Event Flat
* Created by: huy.pham
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-12      huy.pham        [MOI, O_VP_75] Flat table ClickHouse: Fact Securities
*                                 Offering Event x Calendar Date Dim.
*                                 Grain = 1 đợt phát hành × 1 phương thức × 1 loại CK
*                                 × 1 kỳ kết quả. 3 nguồn IDS/SCMS(chờ)/FMS.
*                                 cdr_dt = certificate_dt, derive từ certificate_dt_dim_id.
*                                 ck_snapshot: ghi đè toàn bộ theo ds_snpst_dt = etl_date.
* 2026-11-17      claude          [SỬA, O_VP_75] Bổ sung các cột từ datamart: offering_method_
*                                 group_code, raising_capital_ind (INT), has_result_ind (INT),
*                                 bond_term_years, issue_interest_rate, industry_code,
*                                 foreign_result_val_amt, administrative_procedure_code.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_SECURITIES_OFFERING_EVENT
    CAST(f.securities_offering_event_id    AS string)           AS securities_offering_event_id,
    CAST(f.certificate_dt_dim_id           AS string)           AS certificate_dt_dim_id,
    CAST(f.issuer_tp_code                  AS string)           AS issuer_tp_code,
    CAST(f.issuer_code                     AS string)           AS issuer_code,
    CAST(f.equity_ticker_symbol            AS string)           AS equity_ticker_symbol,
    CAST(f.offering_code                   AS string)           AS offering_code,
    CAST(f.certificate_nbr                 AS string)           AS certificate_nbr,
    CAST(f.certificate_dt                  AS date)             AS certificate_dt,
    CAST(f.offering_round_key              AS string)           AS offering_round_key,
    CAST(f.security_tp_code                AS string)           AS security_tp_code,
    CAST(f.offering_method_code            AS string)           AS offering_method_code,
    CAST(f.security_nm                     AS string)           AS security_nm,
    CAST(f.offering_method_group_code      AS string)           AS offering_method_group_code,
    CAST(f.raising_capital_ind             AS int)              AS raising_capital_ind,
    CAST(f.plan_qty                        AS bigint)           AS plan_quantity,
    CAST(f.plan_amt                        AS decimal(23,2))    AS plan_val_amt,
    CAST(f.result_qty                      AS bigint)           AS result_quantity,
    CAST(f.result_val_amt                      AS decimal(23,2))    AS result_val_amt,
    CAST(f.has_result_ind                  AS int)              AS has_result_ind,
    CAST(f.result_rpt_dt                   AS date)             AS result_rpt_dt,
    CAST(f.bond_term_years                 AS decimal(10,4))    AS bond_term_years,
    CAST(f.issue_interest_rate             AS decimal(5,2))     AS issue_interest_rate,
    CAST(f.src_stm_code                    AS string)           AS src_stm_code,
    CAST(f.industry_code                   AS string)           AS industry_code,
    CAST(f.foreign_result_val_amt          AS decimal(23,2))    AS foreign_result_val_amt,
    CAST(f.administrative_procedure_code   AS string)           AS administrative_procedure_code,

    -- From: CALENDAR DATE DIMENSION (theo ngay cap phep / cong van)
    CAST(cal.cdr_dt                        AS date)             AS cdr_dt,
    CAST(cal.year                          AS bigint)           AS year,
    CAST(cal.quarter                       AS bigint)           AS quarter,
    CAST(cal.month                         AS bigint)           AS month

FROM {{ ref('dtm_fct_securities_offering_event') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.certificate_dt_dim_id
