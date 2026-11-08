/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_alert_history
* Program name: Staging MRMS.RISK_ALERT_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(alert_id AS string)          AS alert_id
    , CAST(resolution_id AS string)     AS resolution_id
    , CAST(event_type AS int)           AS event_type
    , CAST(event_time AS timestamp)     AS event_time
    , CAST(event_title AS string)       AS event_title
    , CAST(event_description AS string) AS event_description
    , CAST(event_user_id AS string)     AS event_user_id
    , CAST(event_user_name AS string)   AS event_user_name
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_mrms', 'raw_risk_alert_history') }}