/*
*--------------------------------------------------------------------*
* Program code: stg_audit_rep_forms
* Program name: Staging AUDIT.REP_FORMS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (1 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(report_cd AS string)         AS report_cd
    , CAST(report_name_vi AS string)    AS report_name_vi
    , CAST(report_name_en AS string)    AS report_name_en
    , CAST(rp_report_type_cd AS string) AS rp_report_type_cd
    , CAST(published_flg AS int)        AS published_flg
    , CAST(report_link AS string)       AS report_link
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS timestamp)   AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS timestamp)   AS updated_date
    , CAST(delete_flg AS int)           AS delete_flg
    , CAST(system_cd AS string)         AS system_cd
FROM {{ source('source_audit', 'raw_rep_forms') }}