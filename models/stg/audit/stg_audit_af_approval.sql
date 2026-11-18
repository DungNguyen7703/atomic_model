/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_approval
* Program name: Staging AUDIT.AF_APPROVAL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (3 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(af_profile_id AS bigint)             AS af_profile_id
    , CAST(af_auditor_profile_id AS bigint)     AS af_auditor_profile_id
    , CAST(target_type_cd AS string)            AS target_type_cd
    , CAST(source_type_cd AS string)            AS source_type_cd
    , CAST(approval_doc_no AS string)           AS approval_doc_no
    , CAST(approval_issue_date AS date)         AS approval_issue_date
    , CAST(approval_start_date AS date)         AS approval_start_date
    , CAST(approval_end_date AS date)           AS approval_end_date
    , CAST(approval_content AS string)          AS approval_content
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS timestamp)           AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS timestamp)           AS updated_date
    , CAST(delete_flg AS int)                   AS delete_flg
    , CAST(affiliation_end_date AS date)        AS affiliation_end_date
    , CAST(affiliation_no AS string)            AS affiliation_no
    , CAST(affiliation_change_reason AS string) AS affiliation_change_reason
FROM {{ source('source_audit', 'raw_af_approval') }}