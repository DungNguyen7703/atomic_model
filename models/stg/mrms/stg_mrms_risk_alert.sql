/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_alert
* Program name: Staging MRMS.RISK_ALERT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(alert_config_id AS string)        AS alert_config_id
    , CAST(indicator_type AS int)            AS indicator_type
    , CAST(indicator_id AS string)           AS indicator_id
    , CAST(custom_indicator_id AS string)    AS custom_indicator_id
    , CAST(period_date AS timestamp)         AS period_date
    , CAST(current_value AS decimal(19,4))   AS current_value
    , CAST(previous_value AS decimal(19,4))  AS previous_value
    , CAST(change_amount AS decimal(19,4))   AS change_amount
    , CAST(change_percent AS decimal(10,4))  AS change_percent
    , CAST(threshold_direction AS int)       AS threshold_direction
    , CAST(threshold_unit_code AS int)       AS threshold_unit_code
    , CAST(alert_message AS string)          AS alert_message
    , CAST(triggered_at AS timestamp)        AS triggered_at
    , CAST(triggered_by_job_id AS string)    AS triggered_by_job_id
    , CAST(handler_user_id AS string)        AS handler_user_id
    , CAST(handler_user_name AS string)      AS handler_user_name
    , CAST(status AS int)                    AS status
    , CAST(assigned_at AS timestamp)         AS assigned_at
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(created_by_id AS string)          AS created_by_id
    , CAST(updated_by_id AS string)          AS updated_by_id
    , CAST(created_by_name AS string)        AS created_by_name
    , CAST(updated_by_name AS string)        AS updated_by_name
    , CAST(deleted AS int)                   AS deleted
    , CAST(compare_period_time AS int)       AS compare_period_time
    , CAST(threshold_value AS decimal(19,4)) AS threshold_value
    , CAST(is_expired AS int)                AS is_expired
    , CAST(toast_dismissed AS int)           AS toast_dismissed
    , CAST(toast_dismissed_at AS timestamp)  AS toast_dismissed_at
    , CAST(alert_type AS int)                AS alert_type
FROM {{ source('source_mrms', 'raw_risk_alert') }}