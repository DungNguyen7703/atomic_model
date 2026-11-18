/*
*--------------------------------------------------------------------*
* Program code: stg_tms_metric_catalog_relationship
* Program name: Staging TMS.METRIC_CATALOG_RELATIONSHIP
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
    , CAST(metric_id_1 AS string)     AS metric_id_1
    , CAST(metric_id_2 AS string)     AS metric_id_2
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_metric_catalog_relationship') }}