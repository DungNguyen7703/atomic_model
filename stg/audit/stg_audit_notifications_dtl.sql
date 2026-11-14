/*
*--------------------------------------------------------------------*
* Program code: stg_audit_notifications_dtl
* Program name: Staging AUDIT.NOTIFICATIONS_DTL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (4 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(notifications_id AS bigint)    AS notifications_id
    , CAST(login_id AS bigint)            AS login_id
    , CAST(full_name AS string)           AS full_name
    , CAST(email AS string)               AS email
    , CAST(tel AS string)                 AS tel
    , CAST(object_type AS int)            AS object_type
    , CAST(dept_cd AS string)             AS dept_cd
    , CAST(login_type AS int)             AS login_type
    , CAST(company_profile_id AS bigint)  AS company_profile_id
    , CAST(equity_listing_exch AS string) AS equity_listing_exch
    , CAST(created_by AS string)          AS created_by
    , CAST(created_date AS timestamp)     AS created_date
    , CAST(updated_by AS string)          AS updated_by
    , CAST(updated_date AS timestamp)     AS updated_date
    , CAST(delete_flg AS int)             AS delete_flg
FROM {{ source('source_audit', 'raw_notifications_dtl') }}