/*
*--------------------------------------------------------------------*
* Program code: stg_audit_data
* Program name: Staging AUDIT.DATA
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))         AS id
    , CAST(report_catalog_id AS int)    AS report_catalog_id
    , CAST(data_value AS decimal(38,2)) AS data_value
    , CAST(report_year AS int)          AS report_year
    , CAST(report_quarter AS int)       AS report_quarter
    , CAST(cell_enabled_flg AS int)     AS cell_enabled_flg
    , CAST(rc_type AS string)           AS rc_type
    , CAST(row_cd AS string)            AS row_cd
    , CAST(col_cd AS string)            AS col_cd
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
    , CAST(company_profile_id AS int)   AS company_profile_id
FROM {{ source('source_audit', 'raw_data') }}