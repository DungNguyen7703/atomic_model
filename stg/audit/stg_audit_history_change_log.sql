/*
*--------------------------------------------------------------------*
* Program code: stg_audit_history_change_log
* Program name: Staging AUDIT.HISTORY_CHANGE_LOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)             AS id
    , CAST(table_name AS string)     AS table_name
    , CAST(object_id AS string)      AS object_id
    , CAST(action AS string)         AS action
    , CAST(changed_by AS string)     AS changed_by
    , CAST(changed_at AS timestamp)  AS changed_at
    , CAST(source_service AS string) AS source_service
    , CAST(before_data AS string)    AS before_data
    , CAST(after_data AS string)     AS after_data
    , CAST(changed_fields AS string) AS changed_fields
FROM {{ source('source_audit', 'raw_history_change_log') }}