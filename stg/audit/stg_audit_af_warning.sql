/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_warning
* Program name: Staging AUDIT.AF_WARNING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(af_profile_id AS int)         AS af_profile_id
    , CAST(af_auditor_profile_id AS int) AS af_auditor_profile_id
    , CAST(target_type_cd AS string)     AS target_type_cd
    , CAST(source_type_cd AS string)     AS source_type_cd
    , CAST(warning_doc_no AS string)     AS warning_doc_no
    , CAST(warning_issue_date AS date)   AS warning_issue_date
    , CAST(warning_start_date AS date)   AS warning_start_date
    , CAST(warning_end_date AS date)     AS warning_end_date
    , CAST(warning_content AS string)    AS warning_content
    , CAST(warning_type_cd AS string)    AS warning_type_cd
    , CAST(af_inspection_id AS int)      AS af_inspection_id
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS date)         AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS date)         AS updated_date
    , CAST(delete_flg AS int)            AS delete_flg
FROM {{ source('source_audit', 'raw_af_warning') }}