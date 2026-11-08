/*
*--------------------------------------------------------------------*
* Program code: stg_audit_sms_log
* Program name: Staging AUDIT.SMS_LOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(send_date AS timestamp)     AS send_date
    , CAST(phone_no AS string)         AS phone_no
    , CAST(status AS string)           AS status
    , CAST(notification_id AS int)     AS notification_id
    , CAST(form_id AS int)             AS form_id
    , CAST(form_code AS string)        AS form_code
    , CAST(sms_type_cd AS string)      AS sms_type_cd
    , CAST(created_by AS string)       AS created_by
    , CAST(created_date AS timestamp)  AS created_date
    , CAST(updated_by AS string)       AS updated_by
    , CAST(updated_date AS timestamp)  AS updated_date
    , CAST(company_profiles_id AS int) AS company_profiles_id
FROM {{ source('source_audit', 'raw_sms_log') }}