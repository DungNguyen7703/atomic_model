/*
*--------------------------------------------------------------------*
* Program code: stg_audit_databasechangeloglock
* Program name: Staging AUDIT.DATABASECHANGELOGLOCK
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)             AS id
    , CAST(locked AS int)            AS locked
    , CAST(lockgranted AS timestamp) AS lockgranted
    , CAST(lockedby AS string)       AS lockedby
FROM {{ source('source_audit', 'raw_databasechangeloglock') }}