/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_alert_resolution
* Program name: Staging MRMS.RISK_ALERT_RESOLUTION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(alert_id AS string)            AS alert_id
    , CAST(resolution_type AS int)        AS resolution_type
    , CAST(explanation_content AS string) AS explanation_content
    , CAST(resolved_at AS timestamp)      AS resolved_at
    , CAST(resolved_by_id AS string)      AS resolved_by_id
    , CAST(resolved_by_name AS string)    AS resolved_by_name
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_by_name AS string)     AS updated_by_name
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_mrms', 'raw_risk_alert_resolution') }}