/*
*--------------------------------------------------------------------*
* Program code: stg_scms_auditor
* Program name: Staging SCMS.AUDITOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: approval_date, approval_revocation_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(audit_firm_id AS bigint)          AS audit_firm_id
    , CAST(full_name AS string)              AS full_name
    , CAST(certificate_number AS string)     AS certificate_number
    , CAST(issue_date AS timestamp)          AS issue_date
    , CAST(approval_date AS date)       AS approval_date
    , CAST(approval_revocation_date AS date) AS approval_revocation_date
    , CAST(note AS string)                   AS note
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(record_status AS int)             AS record_status
FROM {{ source('source_scms', 'raw_auditor') }}