/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_approved_auditors
* Program name: Staging ECAT.APPROVED_AUDITORS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(stable_id AS string)                    AS stable_id
    , CAST(code AS string)                         AS code
    , CAST(full_name AS string)                    AS full_name
    , CAST(af_profile_id AS string)                AS af_profile_id
    , CAST(af_profile_version_id AS string)        AS af_profile_version_id
    , CAST(audit_practice_cert_no AS string)       AS audit_practice_cert_no
    , CAST(position_title_id AS string)            AS position_title_id
    , CAST(position_title_version_id AS string)    AS position_title_version_id
    , CAST(mof_approval_doc_no AS string)          AS mof_approval_doc_no
    , CAST(mof_approval_issue_date AS timestamp)   AS mof_approval_issue_date
    , CAST(mof_approval_start_date AS timestamp)   AS mof_approval_start_date
    , CAST(mof_approval_end_date AS timestamp)     AS mof_approval_end_date
    , CAST(mof_approval_content AS string)         AS mof_approval_content
    , CAST(ssc_approval_doc_no AS string)          AS ssc_approval_doc_no
    , CAST(ssc_approval_issue_date AS timestamp)   AS ssc_approval_issue_date
    , CAST(ssc_approval_start_date AS timestamp)   AS ssc_approval_start_date
    , CAST(ssc_approval_end_date AS timestamp)     AS ssc_approval_end_date
    , CAST(ssc_approval_content AS string)         AS ssc_approval_content
    , CAST(mof_suspension_doc_no AS string)        AS mof_suspension_doc_no
    , CAST(mof_suspension_issue_date AS timestamp) AS mof_suspension_issue_date
    , CAST(mof_suspension_start_date AS timestamp) AS mof_suspension_start_date
    , CAST(mof_suspension_end_date AS timestamp)   AS mof_suspension_end_date
    , CAST(mof_suspension_content AS string)       AS mof_suspension_content
    , CAST(ssc_suspension_doc_no AS string)        AS ssc_suspension_doc_no
    , CAST(ssc_suspension_issue_date AS timestamp) AS ssc_suspension_issue_date
    , CAST(ssc_suspension_start_date AS timestamp) AS ssc_suspension_start_date
    , CAST(ssc_suspension_end_date AS timestamp)   AS ssc_suspension_end_date
    , CAST(ssc_suspension_content AS string)       AS ssc_suspension_content
    , CAST(accept_year AS timestamp)               AS accept_year
    , CAST(affiliation_end_date AS timestamp)      AS affiliation_end_date
    , CAST(rec_changed_flg AS int)                 AS rec_changed_flg
    , CAST(status AS int)                          AS status
    , CAST(active_reason AS string)                AS active_reason
    , CAST(deleted AS int)                         AS deleted
    , CAST(deleted_reason AS string)               AS deleted_reason
    , CAST(version AS int)                         AS version
    , CAST(effective_start_date AS timestamp)      AS effective_start_date
    , CAST(effective_end_date AS timestamp)        AS effective_end_date
    , CAST(old_id AS string)                       AS old_id
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(created_by AS string)                   AS created_by
    , CAST(created_date AS timestamp)              AS created_date
    , CAST(last_updated_by AS string)              AS last_updated_by
    , CAST(last_updated_date AS timestamp)         AS last_updated_date
FROM {{ source('source_ecat', 'raw_approved_auditors') }}