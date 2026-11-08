/*
*--------------------------------------------------------------------*
* Program code: stg_audit_notifications_result
* Program name: Staging AUDIT.NOTIFICATIONS_RESULT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                 AS id
    , CAST(notification_id AS decimal(19,0))    AS notification_id
    , CAST(login_id AS decimal(19,0))           AS login_id
    , CAST(noti_category_cd AS string)          AS noti_category_cd
    , CAST(form_id AS decimal(19,0))            AS form_id
    , CAST(company_data_id AS decimal(19,0))    AS company_data_id
    , CAST(company_profile_id AS decimal(19,0)) AS company_profile_id
    , CAST(title AS string)                     AS title
    , CAST(content AS string)                   AS content
    , CAST(sent_date AS date)                   AS sent_date
    , CAST(read_flg AS int)                     AS read_flg
    , CAST(read_date AS date)                   AS read_date
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS date)                AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS date)                AS updated_date
FROM {{ source('source_audit', 'raw_notifications_result') }}