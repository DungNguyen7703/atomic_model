/*
*--------------------------------------------------------------------*
* Program code: vp_fct_foreign_capital_flow_summary_snpst_flat
* Program name: VP Fct Foreign Capital Flow Summary Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-06      huy.pham        [MOI] Flat table ClickHouse: Fact Foreign Capital Flow
*                                 Summary Snapshot x Calendar Date Dim.
*                                 Grain = 1 doi tuong nop (TVLK) x 1 ky bao cao nua thang.
*                                 JOIN cal theo snpst_dt_dim_id (yyyyMMdd submission_dt).
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_FOREIGN_CAPITAL_FLOW_SUMMARY_SNPST
    CAST(f.foreign_capital_flow_summary_snpst_id   AS string)           AS foreign_capital_flow_summary_snpst_id,
    CAST(f.snpst_dt_dim_id                         AS string)           AS snpst_dt_dim_id,
    CAST(f.rpt_dt_dim_id                           AS string)           AS rpt_dt_dim_id,
    CAST(f.reporting_entity_code                   AS string)           AS reporting_entity_code,
    CAST(f.period_val                              AS string)           AS period_val,
    CAST(f.rpt_year                                AS int)              AS rpt_year,
    CAST(f.capital_flow_net_val                    AS decimal(38,15))   AS capital_flow_net_val,
    CAST(f.capital_inflow_val                      AS decimal(38,15))   AS capital_inflow_val,
    CAST(f.capital_outflow_val                     AS decimal(38,15))   AS capital_outflow_val,
    CAST(f.src_stm_code                            AS string)           AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION (theo ngay nop bao cao)
    CAST(to_date(f.rpt_dt_dim_id, 'yyyyMMdd')      AS date)            AS cdr_dt,
    CAST(cal.year                                  AS bigint)           AS year,
    CAST(cal.quarter                               AS bigint)           AS quarter,
    CAST(cal.month                                 AS bigint)           AS month,
    CAST(cal.day_of_week                           AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                            AS string)           AS is_weekend,
    CAST(cal.holiday_flag                          AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                       AS string)           AS is_trading_date

FROM {{ ref('dtm_fct_foreign_capital_flow_summary_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.rpt_dt_dim_id
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
