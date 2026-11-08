/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_indicator_value
* Program name: Staging MRMS.RISK_INDICATOR_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(indicator_id AS string)            AS indicator_id
    , CAST(period_type AS int)                AS period_type
    , CAST(period_value AS int)               AS period_value
    , CAST(period_year AS int)                AS period_year
    , CAST(period_date AS timestamp)          AS period_date
    , CAST(period_label AS string)            AS period_label
    , CAST(unit_code AS int)                  AS unit_code
    , CAST(source_code AS int)                AS source_code
    , CAST(data_origin AS int)                AS data_origin
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(deleted AS int)                    AS deleted
    , CAST(cumulative_value AS decimal(19,4)) AS cumulative_value
    , CAST(value AS decimal(19,4))            AS value
FROM {{ source('source_mrms', 'raw_risk_indicator_value') }}