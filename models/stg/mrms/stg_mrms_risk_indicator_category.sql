/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_indicator_category
* Program name: Staging MRMS.RISK_INDICATOR_CATEGORY
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
    , CAST(set_code AS int)           AS set_code
    , CAST(category_code AS string)   AS category_code
    , CAST(category_name AS string)   AS category_name
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_mrms', 'raw_risk_indicator_category') }}