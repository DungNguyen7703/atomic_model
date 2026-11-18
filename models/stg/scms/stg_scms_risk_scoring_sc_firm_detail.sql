/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_scoring_sc_firm_detail
* Program name: Staging SCMS.RISK_SCORING_SC_FIRM_DETAIL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (8 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: sc_firm_info_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(risk_scoring_sc_firm_id AS bigint) AS risk_scoring_sc_firm_id
    , CAST(risk_indicator_id AS bigint)      AS risk_indicator_id
    , CAST(risk_scoring_scale_id AS bigint)  AS risk_scoring_scale_id
    , CAST(weight AS decimal(6,2))           AS weight
    , CAST(item_value AS string)             AS item_value
    , CAST(indicator_score AS decimal(18,2)) AS indicator_score
    , CAST(score AS decimal(18,2))           AS score
    , CAST(note AS string)                   AS note
    , CAST(created_by AS bigint)             AS created_by
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_by AS bigint)       AS last_modified_by
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(record_status AS int)             AS record_status
    , CAST(risk_indicator_group_id AS bigint) AS risk_indicator_group_id
    , CAST(risk_reporting_period_id AS bigint) AS risk_reporting_period_id
    , CAST(record_type AS string)            AS record_type
    , CAST(sc_firm_info_id AS bigint)           AS sc_firm_info_id
    , CAST(implementation_method AS int)     AS implementation_method
    , CAST(formula_text AS string)           AS formula_text
    , CAST(formula AS string)                AS formula
    , CAST(sum_formula AS string)            AS sum_formula
FROM {{ source('source_scms', 'raw_risk_scoring_sc_firm_detail') }}