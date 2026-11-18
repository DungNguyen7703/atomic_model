/*
*--------------------------------------------------------------------*
* Program code: atm_violation_report
* Program name: Atomic Violation Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH vi_re AS (
    SELECT
        id
        , company_profile_id
        , violation_template_id
        , form_cd
        , period_name
        , period_quarter
        , period_year
        , base_column
        , base_date
        , deadline_date
        , actual_submit_date
        , status
        , original_deadline
        , language_cd
    FROM {{ ref('ods_ids_violation_report') }}
),

vi_te AS (
    SELECT
        id
        , violation_cd
    FROM {{ ref('ods_ids_violation_templates') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_VIOLATION_REPORT', "vi_re.id") }}                   AS vr_id
    , CAST(vi_re.id AS string)                                                                AS vr_code
    , CAST('IDS_VIOLATION_REPORT' AS string)                                                  AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "vi_re.company_profile_id") }} AS pc_id
    , CAST(vi_re.company_profile_id AS string)                                                AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_VIOLATION_TEMPLATES', "vi_te.violation_cd") }}    AS vr_template_id
    , CAST(vi_te.violation_cd AS string)                                                      AS vr_template_code
    , {{ generate_surrogate_key_bigint('IDS_FORMS', "vi_re.form_cd") }}                       AS fr_template_id
    , CAST(vi_re.form_cd AS string)                                                           AS fr_template_code
    , CAST(vi_re.period_name AS string)                                                       AS period_nm
    , CAST(vi_re.period_quarter AS string)                                                    AS quarter_tp_code
    , CAST(vi_re.period_year AS int)                                                          AS period_year
    , CAST(vi_re.base_column AS string)                                                       AS base_column_nm
    , CAST(vi_re.base_date AS date)                                                           AS base_dt
    , CAST(vi_re.deadline_date AS date)                                                       AS deadline_dt
    , CAST(vi_re.actual_submit_date AS date)                                                  AS actual_submit_dt
    , CAST(vi_re.status AS string)                                                            AS submission_status_code
    , CAST(vi_re.original_deadline AS date)                                                   AS original_deadline_dt
    , CAST(vi_re.language_cd AS string)                                                       AS language_code
FROM vi_re
    LEFT JOIN vi_te ON vi_re.VIOLATION_TEMPLATE_ID = vi_te.ID