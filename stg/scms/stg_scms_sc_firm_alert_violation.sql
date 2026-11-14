/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_alert_violation
* Program name: Staging SCMS.SC_FIRM_ALERT_VIOLATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (9 cot); kieu int sang decimal(19,0) (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(sc_firm_info_id AS bigint)       AS sc_firm_info_id
    , CAST(severity_level AS int)           AS severity_level
    , CAST(condition AS string)             AS condition
    , CAST(compare_value AS int)            AS compare_value
    , CAST(actual_value AS decimal(38,2))   AS actual_value
    , CAST(note AS string)                  AS note
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(alert_indicator_id AS bigint)    AS alert_indicator_id
    , CAST(alert_year AS string)            AS alert_year
    , CAST(report_period AS string)         AS report_period
    , CAST(report_period_value AS string)   AS report_period_value
    , CAST(resolved AS int)                 AS resolved
    , CAST(deducted_score AS decimal(38,2)) AS deducted_score
    , CAST(resolution_note AS string)       AS resolution_note
    , CAST(period AS bigint)                AS period
    , CAST(violation_description AS string) AS violation_description
    , CAST(violation_severity AS bigint)    AS violation_severity
    , CAST(report_year AS bigint)           AS report_year
    , CAST(processing_date AS timestamp)    AS processing_date
    , CAST(created_by AS bigint)            AS created_by
    , CAST(processor_id AS bigint)          AS processor_id
    , CAST(threshold AS decimal(38,2))      AS threshold
    , CAST(alert_condition_id AS decimal(19,0)) AS alert_condition_id
    , CAST(entity_type AS string)           AS entity_type
    , CAST(entity_id AS decimal(19,0))      AS entity_id
    , CAST(alert_run_id AS decimal(19,0))   AS alert_run_id
    , CAST(period_type AS int)              AS period_type
    , CAST(period_value AS bigint)          AS period_value
    , CAST(alert_date AS date)              AS alert_date
    , CAST(severity_level_alt AS int)       AS severity_level_alt
    , CAST(string_result_value AS string)   AS string_result_value
FROM {{ source('source_scms', 'raw_sc_firm_alert_violation') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1