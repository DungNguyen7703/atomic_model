/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_indicator_custom
* Program name: Staging MRMS.RISK_INDICATOR_CUSTOM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(indicator_name AS string)  AS indicator_name
    , CAST(unit_code AS int)          AS unit_code
    , CAST(source_code AS string)     AS source_code
    , CAST(period_type AS int)        AS period_type
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_mrms', 'raw_risk_indicator_custom') }}