/*
*--------------------------------------------------------------------*
* Program code: stg_audit_holiday_calendar
* Program name: Staging AUDIT.HOLIDAY_CALENDAR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(name AS string)           AS name
    , CAST(holiday_date AS date)     AS holiday_date
    , CAST(holiday_end_date AS date) AS holiday_end_date
    , CAST(created_by AS string)     AS created_by
    , CAST(holiday_type AS string)   AS holiday_type
    , CAST(created_date AS date)     AS created_date
    , CAST(updated_by AS string)     AS updated_by
    , CAST(updated_date AS date)     AS updated_date
    , CAST(year AS int)              AS year
    , CAST(code AS string)           AS code
    , CAST(active_flg AS int)        AS active_flg
    , CAST(delete_flg AS int)        AS delete_flg
    , CAST(version AS int)           AS version
    , CAST(is_sync AS int)           AS is_sync
    , CAST(system_cd AS string)      AS system_cd
FROM {{ source('source_audit', 'raw_holiday_calendar') }}