/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_summary_detail
* Program name: Staging SCMS.RISK_SUMMARY_DETAIL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: sc_firm_info_id, risk_reporting_period_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(risk_summary_id AS bigint)       AS risk_summary_id
    , CAST(risk_indicator_group_id AS bigint) AS risk_indicator_group_id
    , CAST(total_score AS decimal(38,2))    AS total_score
    , CAST(note AS string)                  AS note
    , CAST(created_by AS bigint)            AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS bigint)      AS last_modified_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(record_status AS int)            AS record_status
    , CAST(sc_firm_info_id AS bigint)          AS sc_firm_info_id
    , CAST(risk_reporting_period_id AS bigint) AS risk_reporting_period_id
FROM {{ source('source_scms', 'raw_risk_summary_detail') }}