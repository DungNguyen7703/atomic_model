/*
*--------------------------------------------------------------------*
* Program code: stg_audit_hte_notifications_dtl
* Program name: Staging AUDIT.HTE_NOTIFICATIONS_DTL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(delete_flg AS int)                   AS delete_flg
    , CAST(login_type AS int)                   AS login_type
    , CAST(object_type AS int)                  AS object_type
    , CAST(rn_ AS int)                          AS rn_
    , CAST(company_profile_id AS decimal(19,0)) AS company_profile_id
    , CAST(id AS decimal(19,0))                 AS id
    , CAST(login_id AS decimal(19,0))           AS login_id
    , CAST(notifications_id AS decimal(19,0))   AS notifications_id
    , CAST(dept_cd AS string)                   AS dept_cd
    , CAST(email AS string)                     AS email
    , CAST(equity_listing_exch AS string)       AS equity_listing_exch
    , CAST(full_name AS string)                 AS full_name
    , CAST(tel AS string)                       AS tel
FROM {{ source('source_audit', 'raw_hte_notifications_dtl') }}