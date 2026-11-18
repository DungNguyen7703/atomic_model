/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_indicator
* Program name: Staging SCMS.RISK_INDICATOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang decimal(38,10): default_value.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(indicator_code AS string)      AS indicator_code
    , CAST(indicator_name AS string)      AS indicator_name
    , CAST(weight AS decimal(6,2))        AS weight
    , CAST(description AS string)         AS description
    , CAST(implementation_method AS int)  AS implementation_method
    , CAST(created_by AS bigint)          AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS bigint)    AS last_modified_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(default_value AS decimal(38,10))          AS default_value
    , CAST(record_status AS int)          AS record_status
    , CAST(record_type AS string)         AS record_type
    , CAST(formula AS string)             AS formula
    , CAST(sum_formula AS string)         AS sum_formula
    , CAST(formula_text AS string)        AS formula_text
FROM {{ source('source_scms', 'raw_risk_indicator') }}