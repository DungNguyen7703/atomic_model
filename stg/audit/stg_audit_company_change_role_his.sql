/*
*--------------------------------------------------------------------*
* Program code: stg_audit_company_change_role_his
* Program name: Staging AUDIT.COMPANY_CHANGE_ROLE_HIS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-06		tuan.nguyenvanb		Theo BRD brd_AUDIT.yaml: data_change_mode Append - yml doi snapshot sang append, partition_by (mngt_start_date); them WHERE loc ngay theo filter_logic.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (3 cot); kieu date sang timestamp (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(username AS string)      AS username
    , CAST(af_profile_id AS bigint)      AS af_profile_id
    , CAST(mngt_start_date AS timestamp) AS mngt_start_date
    , CAST(mngt_end_date AS timestamp)   AS mngt_end_date
    , CAST(change_reason AS string) AS change_reason
    , CAST(changed_date AS timestamp)    AS changed_date
    , CAST(login_id AS bigint)           AS login_id
FROM {{ source('source_audit', 'raw_company_change_role_his') }}
WHERE date_format(mngt_start_date, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(mngt_start_date, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1