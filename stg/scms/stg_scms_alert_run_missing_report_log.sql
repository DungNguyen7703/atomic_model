/*
*--------------------------------------------------------------------*
* Program code: stg_scms_alert_run_missing_report_log
* Program name: Staging SCMS.ALERT_RUN_MISSING_REPORT_LOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                           AS id
    , CAST(alert_run_id AS decimal(19,0))                 AS alert_run_id
    , CAST(alert_indicator_condition_id AS decimal(19,0)) AS alert_indicator_condition_id
    , CAST(subject_type AS string)                        AS subject_type
    , CAST(subject_id AS decimal(19,0))                   AS subject_id
    , CAST(data_year AS int)                              AS data_year
    , CAST(period_type AS int)                            AS period_type
    , CAST(period_value AS bigint)                        AS period_value
    , CAST(created_at AS timestamp)                       AS created_at
    , CAST(alert_indicator_id AS decimal(19,0))           AS alert_indicator_id
    , CAST(reason_note AS string)                         AS reason_note
FROM {{ source('source_scms', 'raw_alert_run_missing_report_log') }}