/*
*--------------------------------------------------------------------*
* Program code: stg_audit_violation_report
* Program name: Staging AUDIT.VIOLATION_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,0))                    AS id
    , CAST(company_profile_id AS decimal(38,0))    AS company_profile_id
    , CAST(violation_template_id AS decimal(38,0)) AS violation_template_id
    , CAST(form_id AS decimal(38,0))               AS form_id
    , CAST(form_cd AS string)                      AS form_cd
    , CAST(period_name AS string)                  AS period_name
    , CAST(period_quarter AS int)                  AS period_quarter
    , CAST(period_year AS int)                     AS period_year
    , CAST(base_column AS string)                  AS base_column
    , CAST(base_date AS date)                      AS base_date
    , CAST(deadline_date AS date)                  AS deadline_date
    , CAST(actual_submit_date AS date)             AS actual_submit_date
    , CAST(status AS string)                       AS status
    , CAST(created_date AS timestamp)              AS created_date
    , CAST(created_by AS string)                   AS created_by
    , CAST(updated_date AS timestamp)              AS updated_date
    , CAST(updated_by AS string)                   AS updated_by
    , CAST(company_data_id AS decimal(19,0))       AS company_data_id
    , CAST(language_cd AS string)                  AS language_cd
    , CAST(original_deadline AS date)              AS original_deadline
FROM {{ source('source_audit', 'raw_violation_report') }}