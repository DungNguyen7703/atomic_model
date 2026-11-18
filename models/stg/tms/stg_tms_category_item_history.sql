/*
*--------------------------------------------------------------------*
* Program code: stg_tms_category_item_history
* Program name: Staging TMS.CATEGORY_ITEM_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(type AS string)             AS type
    , CAST(category_item_id AS string) AS category_item_id
    , CAST(old_value AS string)        AS old_value
    , CAST(new_value AS string)        AS new_value
    , CAST(action_type AS string)      AS action_type
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_tms', 'raw_category_item_history') }}