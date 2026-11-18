/*
*--------------------------------------------------------------------*
* Program code: stg_knt_lnk_user_group
* Program name: Staging KNT.LNK_USER_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)         AS id
    , CAST(user_id AS bigint)       AS user_id
    , CAST(user_group_id AS bigint) AS user_group_id
FROM {{ source('source_knt', 'raw_lnk_user_group') }}