/*
*--------------------------------------------------------------------*
* Program code: stg_fms_agent_id_unify_audit
* Program name: Staging FMS.AGENT_ID_UNIFY_AUDIT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                             AS id
    , HEX(old_job_agent_id)               AS old_job_agent_id
    , HEX(new_id)                         AS new_id
    , CAST(system_object_type AS int)     AS system_object_type
    , CAST(table_name AS string)          AS table_name
    , CAST(rows_touched AS decimal(38,2)) AS rows_touched
    , CAST(note AS string)                AS note
    , CAST(date_created AS timestamp)     AS date_created
FROM {{ source('source_fms', 'raw_agent_id_unify_audit') }}