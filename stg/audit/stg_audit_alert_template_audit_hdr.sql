/*
*--------------------------------------------------------------------*
* Program code: stg_audit_alert_template_audit_hdr
* Program name: Staging AUDIT.ALERT_TEMPLATE_AUDIT_HDR
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
    , CAST(code AS string)           AS code
    , CAST(name AS string)           AS name
    , CAST(description AS string)    AS description
    , CAST(condition_type AS string) AS condition_type
    , CAST(active_flg AS int)        AS active_flg
    , CAST(delete_flg AS int)        AS delete_flg
    , CAST(created_date AS timestamp) AS created_date
    , CAST(created_by AS string)     AS created_by
    , CAST(updated_date AS timestamp) AS updated_date
    , CAST(updated_by AS string)     AS updated_by
FROM {{ source('source_audit', 'raw_alert_template_audit_hdr') }}