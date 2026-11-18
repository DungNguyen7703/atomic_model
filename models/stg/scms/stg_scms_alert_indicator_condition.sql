/*
*--------------------------------------------------------------------*
* Program code: stg_scms_alert_indicator_condition
* Program name: Staging SCMS.ALERT_INDICATOR_CONDITION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (9 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang decimal(38,10): compare_value.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                AS id
    , CAST(alert_indicator_id AS bigint)                AS alert_indicator_id
    , CAST(condition AS string)                         AS condition
    , CAST(compare_value AS decimal(38,10))                        AS compare_value
    , CAST(note AS string)                              AS note
    , CAST(created_by AS bigint)                        AS created_by
    , CAST(created_at AS timestamp)                     AS created_at
    , CAST(last_modified_by_legacy AS bigint)           AS last_modified_by_legacy
    , CAST(last_modified_at_legacy AS timestamp)        AS last_modified_at_legacy
    , CAST(record_status AS int)                        AS record_status
    , CAST(condition_name AS string)                    AS condition_name
    , CAST(upper_condition AS string)                   AS upper_condition
    , CAST(score AS decimal(38,2))                      AS score
    , CAST(item_value AS decimal(38,2))                 AS item_value
    , CAST(value_2 AS decimal(38,2))                    AS value_2
    , CAST(description AS string)                       AS description
    , CAST(severity AS bigint)                          AS severity
    , CAST(last_modified_at AS timestamp)               AS last_modified_at
    , CAST(last_modified_by AS bigint)                  AS last_modified_by
    , CAST(sort_order AS bigint)                        AS sort_order
    , CAST(operator AS string)                          AS operator
    , CAST(frequency AS string)                         AS frequency
    , CAST(comparison_value_type AS string)             AS comparison_value_type
    , CAST(operator_2 AS string)                        AS operator_2
    , CAST(period_type AS int)                          AS period_type
    , CAST(period_value AS bigint)                      AS period_value
    , CAST(run_offset_days AS int)                      AS run_offset_days
    , CAST(max_wait_days AS int)                        AS max_wait_days
    , CAST(condition_type AS int)                       AS condition_type
    , CAST(compare_alert_indicator_id AS decimal(19,0)) AS compare_alert_indicator_id
    , CAST(compare_period_type AS int)                  AS compare_period_type
    , CAST(compare_period_value AS bigint)              AS compare_period_value
    , CAST(compare_operator AS string)                  AS compare_operator
    , CAST(string_compare_value AS string)              AS string_compare_value
    , CAST(severity_level AS int)                       AS severity_level
FROM {{ source('source_scms', 'raw_alert_indicator_condition') }}