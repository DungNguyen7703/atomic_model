/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_indicator
* Program name: Staging MRMS.RISK_INDICATOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(indicator_code AS string)    AS indicator_code
    , CAST(indicator_name AS string)    AS indicator_name
    , CAST(set_code AS int)             AS set_code
    , CAST(category_id AS string)       AS category_id
    , CAST(unit_code AS int)            AS unit_code
    , CAST(source_code AS int)          AS source_code
    , CAST(period_type AS int)          AS period_type
    , CAST(status AS int)               AS status
    , CAST(last_sync_time AS timestamp) AS last_sync_time
    , CAST(display_order AS int)        AS display_order
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
    , CAST(is_display AS int)           AS is_display
    , CAST(show_sync_indicator AS int)  AS show_sync_indicator
FROM {{ source('source_mrms', 'raw_risk_indicator') }}