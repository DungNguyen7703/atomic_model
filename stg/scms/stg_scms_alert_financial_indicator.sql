/*
*--------------------------------------------------------------------*
* Program code: stg_scms_alert_financial_indicator
* Program name: Staging SCMS.ALERT_FINANCIAL_INDICATOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(formula AS string)              AS formula
    , CAST(unit AS string)                 AS unit
    , CAST(indicator_code AS string)       AS indicator_code
    , CAST(description AS string)          AS description
    , CAST(last_modified_at AS timestamp)  AS last_modified_at
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(last_modified_by AS bigint)     AS last_modified_by
    , CAST(created_by AS bigint)           AS created_by
    , CAST(threshold_max AS decimal(38,2)) AS threshold_max
    , CAST(threshold_min AS decimal(38,2)) AS threshold_min
    , CAST(indicator_group_id AS bigint)   AS indicator_group_id
    , CAST(indicator_name AS string)       AS indicator_name
    , CAST(sort_order AS bigint)           AS sort_order
    , CAST(record_status AS int)           AS record_status
    , CAST(weight AS decimal(38,2))        AS weight
FROM {{ source('source_scms', 'raw_alert_financial_indicator') }}