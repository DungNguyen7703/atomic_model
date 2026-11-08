/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_alert_config
* Program name: Staging MRMS.RISK_ALERT_CONFIG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(indicator_type AS int)             AS indicator_type
    , CAST(indicator_id AS string)            AS indicator_id
    , CAST(custom_indicator_id AS string)     AS custom_indicator_id
    , CAST(threshold_direction AS int)        AS threshold_direction
    , CAST(threshold_unit_code AS int)        AS threshold_unit_code
    , CAST(compare_period_time AS int)        AS compare_period_time
    , CAST(alert_message_template AS string)  AS alert_message_template
    , CAST(handler_user_id AS string)         AS handler_user_id
    , CAST(handler_user_name AS string)       AS handler_user_name
    , CAST(notify_bell_flag AS int)           AS notify_bell_flag
    , CAST(notify_email_flag AS int)          AS notify_email_flag
    , CAST(notify_toast_flag AS int)          AS notify_toast_flag
    , CAST(is_active AS int)                  AS is_active
    , CAST(display_order AS int)              AS display_order
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(deleted AS int)                    AS deleted
    , CAST(custom_old_value AS decimal(19,4)) AS custom_old_value
    , CAST(custom_new_value AS decimal(19,4)) AS custom_new_value
    , CAST(threshold_value AS decimal(19,4))  AS threshold_value
    , CAST(alert_type AS int)                 AS alert_type
FROM {{ source('source_mrms', 'raw_risk_alert_config') }}