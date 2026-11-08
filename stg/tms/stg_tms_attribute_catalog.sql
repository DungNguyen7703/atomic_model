/*
*--------------------------------------------------------------------*
* Program code: stg_tms_attribute_catalog
* Program name: Staging TMS.ATTRIBUTE_CATALOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(metric_id AS string)       AS metric_id
    , CAST(attr_code AS string)       AS attr_code
    , CAST(attr_name AS string)       AS attr_name
    , CAST(data_type AS string)       AS data_type
    , CAST(attr_role AS string)       AS attr_role
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
    , CAST(category AS string)        AS category
FROM {{ source('source_tms', 'raw_attribute_catalog') }}