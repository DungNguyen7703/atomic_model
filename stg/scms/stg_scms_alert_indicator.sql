/*
*--------------------------------------------------------------------*
* Program code: stg_scms_alert_indicator
* Program name: Staging SCMS.ALERT_INDICATOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (7 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang decimal(38,10): default_value.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                            AS id
    , CAST(alert_code AS string)                    AS alert_code
    , CAST(alert_name AS string)                    AS alert_name
    , CAST(legal_reference_id AS bigint)            AS legal_reference_id
    , CAST(legal_reference AS string)               AS legal_reference
    , CAST(severity_level AS int)                   AS severity_level
    , CAST(note AS string)                          AS note
    , CAST(default_value AS decimal(38,10))                    AS default_value
    , CAST(created_by AS bigint)                    AS created_by
    , CAST(created_at AS timestamp)                 AS created_at
    , CAST(last_modified_by AS bigint)              AS last_modified_by
    , CAST(last_modified_at AS timestamp)           AS last_modified_at
    , CAST(record_status AS int)                    AS record_status
    , CAST(sum_formula AS string)                   AS sum_formula
    , CAST(formula_text AS string)                  AS formula_text
    , CAST(formula AS string)                       AS formula
    , CAST(alert_indicator_type AS int)             AS alert_indicator_type
    , CAST(unit AS string)                          AS unit
    , CAST(indicator_type_id AS bigint)             AS indicator_type_id
    , CAST(indicator_code AS string)                AS indicator_code
    , CAST(description AS string)                   AS description
    , CAST(severity AS bigint)                      AS severity
    , CAST(lower_threshold AS decimal(38,2))        AS lower_threshold
    , CAST(upper_threshold AS decimal(38,2))        AS upper_threshold
    , CAST(indicator_name AS string)                AS indicator_name
    , CAST(sort_order AS bigint)                    AS sort_order
    , CAST(weight AS decimal(38,2))                 AS weight
    , CAST(legal_basis AS string)                   AS legal_basis
    , CAST(cb_alert_group_id AS decimal(19,0))      AS cb_alert_group_id
    , CAST(result_data_type AS int)                 AS result_data_type
    , CAST(derivative_business_id AS decimal(19,0)) AS derivative_business_id
    , CAST(derivative_business_scope AS int)        AS derivative_business_scope
    , CAST(result_unit_scale AS string)             AS result_unit_scale
FROM {{ source('source_scms', 'raw_alert_indicator') }}