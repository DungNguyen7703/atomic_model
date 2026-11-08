/*
*--------------------------------------------------------------------*
* Program code: stg_knt_schedule_config
* Program name: Staging KNT.SCHEDULE_CONFIG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(type AS int)               AS type
    , CAST(function_id AS int)        AS function_id
    , CAST(frequency AS string)       AS frequency
    , CAST(start_date AS date)        AS start_date
    , CAST(start_hour AS string)      AS start_hour
    , CAST(start_minute AS string)    AS start_minute
    , CAST(status AS string)          AS status
    , CAST(org_unit_id AS int)        AS org_unit_id
    , CAST(cron_expression AS string) AS cron_expression
    , CAST(api_packet_code AS string) AS api_packet_code
FROM {{ source('source_knt', 'raw_schedule_config') }}