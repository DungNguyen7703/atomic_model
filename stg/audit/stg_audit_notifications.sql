/*
*--------------------------------------------------------------------*
* Program code: stg_audit_notifications
* Program name: Staging AUDIT.NOTIFICATIONS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(noti_cd AS string)               AS noti_cd
    , CAST(noti_title_vi AS string)         AS noti_title_vi
    , CAST(noti_title_en AS string)         AS noti_title_en
    , CAST(noti_category_cd AS string)      AS noti_category_cd
    , CAST(form_id AS int)                  AS form_id
    , CAST(form_cd AS string)               AS form_cd
    , CAST(send_schedule_type_cd AS string) AS send_schedule_type_cd
    , CAST(news_status_cd AS string)        AS news_status_cd
    , CAST(sent_date AS date)               AS sent_date
    , CAST(noti_content_vi AS string)       AS noti_content_vi
    , CAST(noti_content_en AS string)       AS noti_content_en
    , CAST(monthly_send_day AS string)      AS monthly_send_day
    , CAST(monthly_send_month AS string)    AS monthly_send_month
    , CAST(news_type_cd AS string)          AS news_type_cd
    , CAST(send_channel_cd AS string)       AS send_channel_cd
    , CAST(system_cd AS string)             AS system_cd
    , CAST(login_id AS string)              AS login_id
    , CAST(login_name AS string)            AS login_name
    , CAST(object_type AS string)           AS object_type
    , CAST(recipient_type_cd AS string)     AS recipient_type_cd
    , CAST(equity_listing_exch AS string)   AS equity_listing_exch
    , CAST(active_flg AS int)               AS active_flg
    , CAST(reminder_before_due_days AS int) AS reminder_before_due_days
    , CAST(send_hour AS string)             AS send_hour
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS date)            AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS date)            AS updated_date
    , CAST(delete_flg AS int)               AS delete_flg
    , CAST(last_fire_date AS date)          AS last_fire_date
FROM {{ source('source_audit', 'raw_notifications') }}