/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_reporting_period_sc_firm
* Program name: Staging SCMS.RISK_REPORTING_PERIOD_SC_FIRM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(risk_reporting_period_id AS bigint) AS risk_reporting_period_id
    , CAST(sc_firm_info_id AS bigint)       AS sc_firm_info_id
    , CAST(note AS string)                  AS note
    , CAST(created_by AS bigint)            AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS bigint)      AS last_modified_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(record_status AS int)            AS record_status
FROM {{ source('source_scms', 'raw_risk_reporting_period_sc_firm') }}