/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_input_submission
* Program name: Atomic Securities Company Report Input Submission
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH re_in_su AS (
    SELECT
        id
        , form_report_id
        , ref_type
        , ref_id
        , form_version_id
        , period_year
    FROM {{ ref('ods_scms_report_input_submission') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_SUBMISSION', "re_in_su.id") }}    AS sc_rpt_input_submission_id
    , CAST(re_in_su.id AS string)                                                         AS sc_rpt_input_submission_code
    , CAST('SCMS_REPORT_INPUT_SUBMISSION' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "re_in_su.form_report_id") }}  AS sc_rpt_id
    , CAST(re_in_su.form_report_id AS string)                                             AS sc_rpt_code
    , CAST(re_in_su.ref_type AS string)                                                   AS ref_tp_code
    , CAST(re_in_su.ref_id AS string)                                                     AS ref_id
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "re_in_su.form_version_id") }} AS sc_rpt_version_id
    , CAST(re_in_su.form_version_id AS string)                                            AS sc_rpt_version_code
    , CAST(re_in_su.period_year AS int)                                                   AS period_year
FROM re_in_su