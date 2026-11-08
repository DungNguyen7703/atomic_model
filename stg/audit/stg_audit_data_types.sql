/*
*--------------------------------------------------------------------*
* Program code: stg_audit_data_types
* Program name: Staging AUDIT.DATA_TYPES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)             AS id
    , CAST(data_type AS string)   AS data_type
    , CAST(ref_type_vi AS string) AS ref_type_vi
    , CAST(ref_type_en AS string) AS ref_type_en
    , CAST(created_by AS string)  AS created_by
    , CAST(created_date AS date)  AS created_date
    , CAST(updated_by AS string)  AS updated_by
    , CAST(updated_date AS date)  AS updated_date
    , CAST(system_cd AS string)   AS system_cd
FROM {{ source('source_audit', 'raw_data_types') }}