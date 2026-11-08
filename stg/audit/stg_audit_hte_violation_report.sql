/*
*--------------------------------------------------------------------*
* Program code: stg_audit_hte_violation_report
* Program name: Staging AUDIT.HTE_VIOLATION_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(actual_submit_date AS date)             AS actual_submit_date
    , CAST(base_date AS date)                      AS base_date
    , CAST(deadline_date AS date)                  AS deadline_date
    , CAST(period_quarter AS int)                  AS period_quarter
    , CAST(period_year AS int)                     AS period_year
    , CAST(rn_ AS int)                             AS rn_
    , CAST(company_profile_id AS decimal(19,0))    AS company_profile_id
    , CAST(created_date AS timestamp)              AS created_date
    , CAST(form_id AS decimal(19,0))               AS form_id
    , CAST(id AS decimal(19,0))                    AS id
    , CAST(updated_date AS timestamp)              AS updated_date
    , CAST(violation_template_id AS decimal(19,0)) AS violation_template_id
    , CAST(base_column AS string)                  AS base_column
    , CAST(created_by AS string)                   AS created_by
    , CAST(form_cd AS string)                      AS form_cd
    , CAST(period_name AS string)                  AS period_name
    , CAST(status AS string)                       AS status
    , CAST(updated_by AS string)                   AS updated_by
FROM {{ source('source_audit', 'raw_hte_violation_report') }}