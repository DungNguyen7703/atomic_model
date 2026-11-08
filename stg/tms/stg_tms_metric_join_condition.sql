/*
*--------------------------------------------------------------------*
* Program code: stg_tms_metric_join_condition
* Program name: Staging TMS.METRIC_JOIN_CONDITION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(metric_catalog_relationship_id AS string) AS metric_catalog_relationship_id
    , CAST(attribute_catalog_id AS string)           AS attribute_catalog_id
    , CAST(created_at AS timestamp)                  AS created_at
    , CAST(updated_at AS timestamp)                  AS updated_at
    , CAST(created_by_id AS string)                  AS created_by_id
    , CAST(created_by_name AS string)                AS created_by_name
    , CAST(updated_by_id AS string)                  AS updated_by_id
    , CAST(updated_by_name AS string)                AS updated_by_name
    , CAST(deleted AS int)                           AS deleted
FROM {{ source('source_tms', 'raw_metric_join_condition') }}