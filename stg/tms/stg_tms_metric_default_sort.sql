/*
*--------------------------------------------------------------------*
* Program code: stg_tms_metric_default_sort
* Program name: Staging TMS.METRIC_DEFAULT_SORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo TMS_ddl_prod.sql, brd_TMS.yaml va khao sat du lieu nguon prod: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(metric_id AS string)       AS metric_id
    , CAST(attribute_id AS string)    AS attribute_id
    , CAST(sort_direction AS string)  AS sort_direction
    , CAST(sort_priority AS bigint)   AS sort_priority
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_metric_default_sort') }}