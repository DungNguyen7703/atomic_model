/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_permission_group_indicator
* Program name: Staging MRMS.PERMISSION_GROUP_INDICATOR
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
    , CAST(group_id AS string)        AS group_id
    , CAST(indicator_id AS string)    AS indicator_id
    , CAST(deleted AS int)            AS deleted
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
FROM {{ source('source_mrms', 'raw_permission_group_indicator') }}