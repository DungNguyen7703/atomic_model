/*
*--------------------------------------------------------------------*
* Program code: stg_audit_report_catalog
* Program name: Staging AUDIT.REPORT_CATALOG
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
    CAST(id AS bigint)                     AS id
    , CAST(report_cd AS string)              AS report_cd
    , CAST(report_name_vi AS string)         AS report_name_vi
    , CAST(report_name_en AS string)         AS report_name_en
    , CAST(rc_type_cd AS string)             AS rc_type_cd
    , CAST(report_year AS string)            AS report_year
    , CAST(report_scope_cd AS string)        AS report_scope_cd
    , CAST(enterprise_type_cd AS string)     AS enterprise_type_cd
    , CAST(consolidated_flg AS int)          AS consolidated_flg
    , CAST(active_flg AS int)                AS active_flg
    , CAST(is_deleted AS int)                AS is_deleted
    , CAST(created_by AS string)             AS created_by
    , CAST(created_date AS timestamp)        AS created_date
    , CAST(updated_by AS string)             AS updated_by
    , CAST(updated_date AS timestamp)        AS updated_date
    , CAST(system_cd AS string)              AS system_cd
    , CAST(financial_statement_cd AS string) AS financial_statement_cd
    , CAST(reporting_period_cd AS string)    AS reporting_period_cd
    , CAST(ref_cd AS string)                 AS ref_cd
FROM {{ source('source_audit', 'raw_report_catalog') }}