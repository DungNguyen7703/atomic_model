/*
*--------------------------------------------------------------------*
* Program code: stg_audit_departments
* Program name: Staging AUDIT.DEPARTMENTS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (1 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(dept_cd AS string)      AS dept_cd
    , CAST(dept_name_vi AS string) AS dept_name_vi
    , CAST(dept_name_en AS string) AS dept_name_en
    , CAST(description AS string)  AS description
    , CAST(created_by AS string)   AS created_by
    , CAST(created_date AS timestamp) AS created_date
    , CAST(updated_by AS string)   AS updated_by
    , CAST(updated_date AS timestamp) AS updated_date
    , CAST(active_flg AS int)      AS active_flg
    , CAST(sync_flg AS int)        AS sync_flg
FROM {{ source('source_audit', 'raw_departments') }}