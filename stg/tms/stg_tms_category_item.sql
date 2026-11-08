/*
*--------------------------------------------------------------------*
* Program code: stg_tms_category_item
* Program name: Staging TMS.CATEGORY_ITEM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(item_code AS string)          AS item_code
    , CAST(item_name AS string)          AS item_name
    , CAST(item_value AS string)         AS item_value
    , CAST(category_config_id AS string) AS category_config_id
    , CAST(position AS decimal(19,0))    AS position
    , CAST(description AS string)        AS description
    , CAST(parent_item_id AS string)     AS parent_item_id
    , CAST(status AS int)                AS status
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(created_by_id AS string)      AS created_by_id
    , CAST(updated_by_id AS string)      AS updated_by_id
    , CAST(created_by_name AS string)    AS created_by_name
    , CAST(updated_by_name AS string)    AS updated_by_name
    , CAST(deleted AS int)               AS deleted
    , CAST(background_color AS string)   AS background_color
    , CAST(text_color AS string)         AS text_color
    , CAST(version AS decimal(19,0))     AS version
FROM {{ source('source_tms', 'raw_category_item') }}