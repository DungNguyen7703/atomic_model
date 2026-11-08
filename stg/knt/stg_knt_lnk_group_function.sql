/*
*--------------------------------------------------------------------*
* Program code: stg_knt_lnk_group_function
* Program name: Staging KNT.LNK_GROUP_FUNCTION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(user_group_id AS int)       AS user_group_id
    , CAST(function_id AS int)         AS function_id
    , CAST(created_at AS date)         AS created_at
    , CAST(created_by AS string)       AS created_by
    , CAST(created_by_id AS int)       AS created_by_id
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(last_modified_by_id AS int) AS last_modified_by_id
    , CAST(permission AS int)          AS permission
FROM {{ source('source_knt', 'raw_lnk_group_function') }}