/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_scoring_scale
* Program name: Staging SCMS.RISK_SCORING_SCALE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(risk_indicator_id AS bigint) AS risk_indicator_id
    , CAST(from_value AS decimal(18,2)) AS from_value
    , CAST(to_value AS decimal(18,2))   AS to_value
    , CAST(item_value AS string)        AS item_value
    , CAST(score AS decimal(18,2))      AS score
    , CAST(note AS string)              AS note
    , CAST(created_by AS bigint)        AS created_by
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(last_modified_by AS bigint)  AS last_modified_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(record_status AS int)        AS record_status
    , CAST(value_condition AS string)   AS value_condition
FROM {{ source('source_scms', 'raw_risk_scoring_scale') }}