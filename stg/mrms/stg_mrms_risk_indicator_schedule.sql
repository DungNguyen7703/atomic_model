/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_indicator_schedule
* Program name: Staging MRMS.RISK_INDICATOR_SCHEDULE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(indicator_id AS string)     AS indicator_id
    , CAST(frequency_type AS int)      AS frequency_type
    , CAST(frequency_value AS int)     AS frequency_value
    , CAST(start_time AS timestamp)    AS start_time
    , CAST(next_run_time AS timestamp) AS next_run_time
    , CAST(last_run_time AS timestamp) AS last_run_time
    , CAST(cron_expression AS string)  AS cron_expression
    , CAST(is_enabled AS int)          AS is_enabled
    , CAST(total_runs AS int)          AS total_runs
    , CAST(last_status AS string)      AS last_status
    , CAST(last_error AS string)       AS last_error
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_mrms', 'raw_risk_indicator_schedule') }}