/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_reporting_period
* Program name: Staging SCMS.RISK_REPORTING_PERIOD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(period AS string)              AS period
    , CAST(report_year AS int)            AS report_year
    , CAST(consolidated AS int)           AS consolidated
    , CAST(scored AS int)                 AS scored
    , CAST(description AS string)         AS description
    , CAST(created_by AS bigint)          AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS bigint)    AS last_modified_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(record_status AS int)          AS record_status
    , CAST(period_value AS string)        AS period_value
FROM {{ source('source_scms', 'raw_risk_reporting_period') }}