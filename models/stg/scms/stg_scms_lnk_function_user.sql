/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_function_user
* Program name: Staging SCMS.LNK_FUNCTION_USER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(function_id AS bigint)     AS function_id
    , CAST(user_id AS bigint)         AS user_id
    , CAST(function_action AS string) AS function_action
FROM {{ source('source_scms', 'raw_lnk_function_user') }}