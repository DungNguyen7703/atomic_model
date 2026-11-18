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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: WHERE loc theo BRD filter_logic; yml snapshot/ds_snpst_dt -> append/date_created theo BRD.
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
WHERE date_format(date_created, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(date_created, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1