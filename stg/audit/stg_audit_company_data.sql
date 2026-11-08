/*
*--------------------------------------------------------------------*
* Program code: stg_audit_company_data
* Program name: Staging AUDIT.COMPANY_DATA
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))              AS id
    , CAST(company_profile_id AS int)        AS company_profile_id
    , CAST(doc_title AS string)              AS doc_title
    , CAST(form_id AS decimal(19,0))         AS form_id
    , CAST(news_status_cd AS string)         AS news_status_cd
    , CAST(report_year AS int)               AS report_year
    , CAST(report_quarter AS int)            AS report_quarter
    , CAST(report_month AS int)              AS report_month
    , CAST(parent_id AS decimal(19,0))       AS parent_id
    , CAST(doc_no AS string)                 AS doc_no
    , CAST(doc_date AS date)                 AS doc_date
    , CAST(doc_summary AS string)            AS doc_summary
    , CAST(doc_sign_date AS date)            AS doc_sign_date
    , CAST(submission_date AS date)          AS submission_date
    , CAST(approval_date AS date)            AS approval_date
    , CAST(rejection_date AS date)           AS rejection_date
    , CAST(submission_deadline_date AS date) AS submission_deadline_date
    , CAST(overdue_days AS decimal(38,0))    AS overdue_days
    , CAST(ref_id AS int)                    AS ref_id
    , CAST(digital_signature_flg AS int)     AS digital_signature_flg
    , CAST(created_by AS string)             AS created_by
    , CAST(created_date AS date)             AS created_date
    , CAST(updated_by AS string)             AS updated_by
    , CAST(updated_date AS date)             AS updated_date
    , CAST(news_type_cd AS string)           AS news_type_cd
    , CAST(reject_reason AS string)          AS reject_reason
    , CAST(review_date AS timestamp)         AS review_date
    , CAST(send_back_date AS timestamp)      AS send_back_date
    , CAST(link_id AS int)                   AS link_id
    , CAST(language_cd AS string)            AS language_cd
    , CAST(alert_audit AS string)            AS alert_audit
    , CAST(system_cd AS string)              AS system_cd
FROM {{ source('source_audit', 'raw_company_data') }}