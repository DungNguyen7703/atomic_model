/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_approved_audit_firm_approval
* Program name: Staging ECAT.APPROVED_AUDIT_FIRM_APPROVAL
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                           AS id
    , CAST(audit_firm_id AS string)                AS audit_firm_id
    , CAST(audit_firm_stable_id AS string)         AS audit_firm_stable_id
    , CAST(af_auditor_profile_id AS string)        AS af_auditor_profile_id
    , CAST(af_auditor_profile_stable_id AS string) AS af_auditor_profile_stable_id
    , CAST(target_type_cd AS string)               AS target_type_cd
    , CAST(source_type_cd AS string)               AS source_type_cd
    , CAST(approval_doc_no AS string)              AS approval_doc_no
    , CAST(approval_issue_date AS timestamp)       AS approval_issue_date
    , CAST(approval_start_date AS timestamp)       AS approval_start_date
    , CAST(approval_end_date AS timestamp)         AS approval_end_date
    , CAST(approval_content AS string)             AS approval_content
    , CAST(id_sync AS decimal(22,0))               AS id_sync
    , CAST(deleted AS int)                         AS deleted
    , CAST(deleted_reason AS string)               AS deleted_reason
    , CAST(version AS decimal(38,10))              AS version
    , CAST(effective_start_date AS timestamp)      AS effective_start_date
    , CAST(effective_end_date AS timestamp)        AS effective_end_date
    , CAST(old_id AS string)                       AS old_id
    , CAST(stable_id AS string)                    AS stable_id
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(created_by AS string)                   AS created_by
    , CAST(created_date AS timestamp)              AS created_date
    , CAST(updated_by AS string)                   AS updated_by
    , CAST(updated_date AS timestamp)              AS updated_date
FROM {{ source('source_ecat', 'raw_approved_audit_firm_approval') }}