/*
*--------------------------------------------------------------------*
* Program code: stg_tms_metric_catalog
* Program name: Staging TMS.METRIC_CATALOG
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
    , CAST(metric_code AS string)     AS metric_code
    , CAST(metric_name AS string)     AS metric_name
    , CAST(category AS string)        AS category
    , CAST(description AS string)     AS description
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
    , CAST(service_url AS string)     AS service_url
    , CAST(sql_template AS string)    AS sql_template
    , CAST(metric_type AS int)        AS metric_type
    , CAST(data_source AS int)        AS data_source
FROM {{ source('source_tms', 'raw_metric_catalog') }}