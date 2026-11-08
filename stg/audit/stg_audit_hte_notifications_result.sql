/*
*--------------------------------------------------------------------*
* Program code: stg_audit_hte_notifications_result
* Program name: Staging AUDIT.HTE_NOTIFICATIONS_RESULT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(read_flg AS int)                     AS read_flg
    , CAST(rn_ AS int)                          AS rn_
    , CAST(company_data_id AS decimal(19,0))    AS company_data_id
    , CAST(company_profile_id AS decimal(19,0)) AS company_profile_id
    , CAST(created_date AS timestamp)           AS created_date
    , CAST(form_id AS decimal(19,0))            AS form_id
    , CAST(id AS decimal(19,0))                 AS id
    , CAST(login_id AS decimal(19,0))           AS login_id
    , CAST(notification_id AS decimal(19,0))    AS notification_id
    , CAST(read_date AS timestamp)              AS read_date
    , CAST(sent_date AS timestamp)              AS sent_date
    , CAST(updated_date AS timestamp)           AS updated_date
    , CAST(noti_category_cd AS string)          AS noti_category_cd
    , CAST(content AS string)                   AS content
    , CAST(created_by AS string)                AS created_by
    , CAST(title AS string)                     AS title
    , CAST(updated_by AS string)                AS updated_by
FROM {{ source('source_audit', 'raw_hte_notifications_result') }}