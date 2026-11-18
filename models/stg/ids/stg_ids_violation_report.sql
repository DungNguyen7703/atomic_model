/*
*--------------------------------------------------------------------*
* Program code: stg_ids_violation_report
* Program name: Staging IDS.VIOLATION_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(company_profile_id AS int)    AS company_profile_id
    , CAST(violation_template_id AS int) AS violation_template_id
    , CAST(form_id AS int)               AS form_id
    , CAST(form_cd AS string)            AS form_cd
    , CAST(period_name AS string)        AS period_name
    , CAST(period_quarter AS int)        AS period_quarter
    , CAST(period_year AS int)           AS period_year
    , CAST(base_column AS string)        AS base_column
    , CAST(base_date AS date)            AS base_date
    , CAST(deadline_date AS date)        AS deadline_date
    , CAST(actual_submit_date AS date)   AS actual_submit_date
    , CAST(status AS string)             AS status
    , CAST(created_date AS timestamp)    AS created_date
    , CAST(created_by AS string)         AS created_by
    , CAST(updated_date AS timestamp)    AS updated_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(language_cd AS string)        AS language_cd
    , CAST(original_deadline AS date)    AS original_deadline
FROM {{ source('source_ids', 'raw_violation_report') }}