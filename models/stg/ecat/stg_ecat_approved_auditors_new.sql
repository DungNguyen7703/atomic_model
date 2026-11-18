/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_approved_auditors_new
* Program name: Staging ECAT.APPROVED_AUDITORS_NEW
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu timestamp sang date (5 cot); kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                AS id
    , CAST(id_sync AS bigint)                           AS id_sync
    , CAST(full_name AS string)                         AS full_name
    , CAST(audit_firm_id AS string)                     AS audit_firm_id
    , CAST(audit_firm_version_id AS string)             AS audit_firm_version_id
    , CAST(personal_document_no AS string)              AS personal_document_no
    , CAST(audit_practice_cert_no AS string)            AS audit_practice_cert_no
    , CAST(audit_practice_cert_issue_date AS date) AS audit_practice_cert_issue_date
    , CAST(practice_start_date AS date)            AS practice_start_date
    , CAST(practice_end_date AS date)              AS practice_end_date
    , CAST(auditor_cert_no AS string)                   AS auditor_cert_no
    , CAST(auditor_cert_issue_date AS date)        AS auditor_cert_issue_date
    , CAST(reduction_date AS date)                 AS reduction_date
    , CAST(active AS int)                               AS active
    , CAST(active_reason AS string)                     AS active_reason
    , CAST(deleted AS int)                              AS deleted
    , CAST(deleted_reason AS string)                    AS deleted_reason
    , CAST(version AS int)                         AS version
    , CAST(effective_start_date AS timestamp)           AS effective_start_date
    , CAST(effective_end_date AS timestamp)             AS effective_end_date
    , CAST(old_id AS string)                            AS old_id
    , CAST(stable_id AS string)                         AS stable_id
    , CAST(created_at AS timestamp)                     AS created_at
    , CAST(updated_at AS timestamp)                     AS updated_at
    , CAST(created_by_id AS string)                     AS created_by_id
    , CAST(created_by_name AS string)                   AS created_by_name
    , CAST(updated_by_id AS string)                     AS updated_by_id
    , CAST(updated_by_name AS string)                   AS updated_by_name
FROM {{ source('source_ecat', 'raw_approved_auditors_new') }}