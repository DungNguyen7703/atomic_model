/*
*--------------------------------------------------------------------*
* Program code: stg_audit_form_field_history
* Program name: Staging AUDIT.FORM_FIELD_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-06		tuan.nguyenvanb		Theo BRD brd_AUDIT.yaml: data_change_mode Append - yml doi snapshot sang append, partition_by (changed_date); them WHERE loc ngay theo filter_logic.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (1 cot); kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(field_id AS decimal(19,0)) AS field_id
    , CAST(form_id AS decimal(19,0))  AS form_id
    , CAST(field_name_vi AS string)   AS field_name_vi
    , CAST(form_name_vi AS string)    AS form_name_vi
    , CAST(action AS int)             AS action
    , CAST(changed_by AS string)      AS changed_by
    , CAST(changed_date AS timestamp) AS changed_date
    , CAST(system_cd AS string)       AS system_cd
FROM {{ source('source_audit', 'raw_form_field_history') }}
WHERE date_format(changed_date, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(changed_date, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1