/*
*--------------------------------------------------------------------*
* Program code: stg_audit_rrow
* Program name: Staging AUDIT.RROW
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
    , CAST(row_name_vi AS string)    AS row_name_vi
    , CAST(row_name_en AS string)    AS row_name_en
    , CAST(row_cd AS string)         AS row_cd
    , CAST(row_type_cd AS string)    AS row_type_cd
    , CAST(row_formula AS string)    AS row_formula
    , CAST(row_index AS int)         AS row_index
    , CAST(report_catalog_id AS int) AS report_catalog_id
    , CAST(report_year AS string)    AS report_year
    , CAST(rc_type_cd AS string)     AS rc_type_cd
    , CAST(delete_flg AS int)        AS delete_flg
    , CAST(created_by AS string)     AS created_by
    , CAST(created_date AS date)     AS created_date
    , CAST(updated_by AS string)     AS updated_by
    , CAST(updated_date AS date)     AS updated_date
    , CAST(description AS string)    AS description
    , CAST(system_cd AS string)      AS system_cd
    , CAST(row_desc AS string)       AS row_desc
    , CAST(formula_desc AS string)   AS formula_desc
FROM {{ source('source_audit', 'raw_rrow') }}