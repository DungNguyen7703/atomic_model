/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_summary
* Program name: Staging SCMS.RISK_SUMMARY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: risk_reporting_period_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(risk_scoring_sc_firm_id AS bigint) AS risk_scoring_sc_firm_id
    , CAST(sc_firm_info_id AS bigint)         AS sc_firm_info_id
    , CAST(period AS string)                  AS period
    , CAST(report_year AS int)                AS report_year
    , CAST(initial_rating AS string)          AS initial_rating
    , CAST(periodic_rating AS string)         AS periodic_rating
    , CAST(total_score AS decimal(38,2))      AS total_score
    , CAST(capital_score AS decimal(38,2))    AS capital_score
    , CAST(asset_score AS decimal(38,2))      AS asset_score
    , CAST(management_score AS decimal(38,2)) AS management_score
    , CAST(earnings_score AS decimal(38,2))   AS earnings_score
    , CAST(liquidity_score AS decimal(38,2))  AS liquidity_score
    , CAST(note AS string)                    AS note
    , CAST(created_by AS bigint)              AS created_by
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_by AS bigint)        AS last_modified_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(record_status AS int)              AS record_status
    , CAST(risk_reporting_period_id AS bigint)   AS risk_reporting_period_id
FROM {{ source('source_scms', 'raw_risk_summary') }}