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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (2 cot); kieu date sang timestamp (2 cot); kieu int sang decimal(38,10) (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(user_group_id AS bigint)               AS user_group_id
    , CAST(function_id AS bigint)                 AS function_id
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(created_by AS string)       AS created_by
    , CAST(created_by_id AS decimal(38,10))       AS created_by_id
    , CAST(last_modified_at AS timestamp)         AS last_modified_at
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(last_modified_by_id AS decimal(38,10)) AS last_modified_by_id
    , CAST(permission AS int)          AS permission
FROM {{ source('source_knt', 'raw_lnk_group_function') }}