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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(notifications_id AS int)       AS notifications_id
    , CAST(login_id AS int)               AS login_id
    , CAST(full_name AS string)           AS full_name
    , CAST(email AS string)               AS email
    , CAST(tel AS string)                 AS tel
    , CAST(object_type AS int)            AS object_type
    , CAST(dept_cd AS string)             AS dept_cd
    , CAST(login_type AS int)             AS login_type
    , CAST(company_profile_id AS int)     AS company_profile_id
    , CAST(equity_listing_exch AS string) AS equity_listing_exch
    , CAST(created_by AS string)          AS created_by
    , CAST(created_date AS date)          AS created_date
    , CAST(updated_by AS string)          AS updated_by
    , CAST(updated_date AS date)          AS updated_date
    , CAST(delete_flg AS int)             AS delete_flg
FROM {{ source('source_audit', 'raw_notifications_dtl') }}