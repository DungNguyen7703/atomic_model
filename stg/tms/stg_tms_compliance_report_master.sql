/*
*--------------------------------------------------------------------*
* Program code: stg_tms_compliance_report_master
* Program name: Staging TMS.COMPLIANCE_REPORT_MASTER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(template_id AS string)         AS template_id
    , CAST(period_type AS string)         AS period_type
    , CAST(period_value AS int)           AS period_value
    , CAST(period_year AS int)            AS period_year
    , CAST(report_period_label AS string) AS report_period_label
    , CAST(submitter_id AS string)        AS submitter_id
    , CAST(submitter_name AS string)      AS submitter_name
    , CAST(submission_date AS timestamp)  AS submission_date
    , CAST(auto_check_status AS int)      AS auto_check_status
    , CAST(auto_check_reason AS string)   AS auto_check_reason
    , CAST(auto_check_date AS timestamp)  AS auto_check_date
    , CAST(approval_status AS int)        AS approval_status
    , CAST(approval_date AS timestamp)    AS approval_date
    , CAST(approver_id AS string)         AS approver_id
    , CAST(approver_name AS string)       AS approver_name
    , CAST(approver_title AS string)      AS approver_title
    , CAST(rejection_reason AS string)    AS rejection_reason
    , CAST(resubmit_from_date AS date)    AS resubmit_from_date
    , CAST(resubmit_to_date AS date)      AS resubmit_to_date
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_by_name AS string)     AS updated_by_name
    , CAST(deleted AS int)                AS deleted
    , CAST(submitter_title AS string)     AS submitter_title
    , CAST(submitter_type AS string)      AS submitter_type
    , CAST(draft_revision AS int)         AS draft_revision
FROM {{ source('source_tms', 'raw_compliance_report_master') }}