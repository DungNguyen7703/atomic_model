/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_auditor_status_history
* Program name: Staging AUDIT.AF_AUDITOR_STATUS_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (2 cot); kieu date sang timestamp (2 cot).
* 2026-11-13		ngoc.pham		Theo BRD brd_AUDIT.yaml (data_change_mode Append) va ODS DDL: yml snapshot -> append, partition_by (data_dt); them cot data_dt cuoi SELECT; them WHERE loc theo filter_logic (created_date OR updated_date).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(af_auditor_profile_id AS bigint) AS af_auditor_profile_id
    , CAST(event_type AS string)         AS event_type
    , CAST(effective_date AS date)       AS effective_date
    , CAST(reason AS string)             AS reason
    , CAST(additional_desc AS string)    AS additional_desc
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS timestamp)       AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS timestamp)       AS updated_date
    , CAST(delete_flg AS int)            AS delete_flg
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AS data_dt
FROM {{ source('source_audit', 'raw_af_auditor_status_history') }}
WHERE (created_date >= TO_TIMESTAMP('{{ var("etl_date") }}')
  AND created_date <  TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY)
   OR (updated_date >= TO_TIMESTAMP('{{ var("etl_date") }}')
  AND updated_date <  TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY)
