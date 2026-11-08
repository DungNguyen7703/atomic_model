/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_suspension
* Program name: Staging AUDIT.AF_SUSPENSION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(af_profile_id AS int)          AS af_profile_id
    , CAST(af_auditor_profile_id AS int)  AS af_auditor_profile_id
    , CAST(target_type_cd AS string)      AS target_type_cd
    , CAST(source_type_cd AS string)      AS source_type_cd
    , CAST(suspension_doc_no AS string)   AS suspension_doc_no
    , CAST(suspension_issue_date AS date) AS suspension_issue_date
    , CAST(suspension_start_date AS date) AS suspension_start_date
    , CAST(suspension_end_date AS date)   AS suspension_end_date
    , CAST(suspension_content AS string)  AS suspension_content
    , CAST(suspension_type_cd AS string)  AS suspension_type_cd
    , CAST(af_inspection_id AS int)       AS af_inspection_id
    , CAST(created_by AS string)          AS created_by
    , CAST(created_date AS date)          AS created_date
    , CAST(updated_by AS string)          AS updated_by
    , CAST(updated_date AS date)          AS updated_date
    , CAST(delete_flg AS int)             AS delete_flg
FROM {{ source('source_audit', 'raw_af_suspension') }}