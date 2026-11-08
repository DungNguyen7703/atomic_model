/*
*--------------------------------------------------------------------*
* Program code: atm_sc_adhoc_report
* Program name: Atomic Securities Company Adhoc Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_ad_re AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_foreign_branch_id
        , bank_id
        , form_report_id
        , form_version_id
        , report_input_submission_id
        , report_name
        , report_year
        , document_number
        , period_value
        , detail_type
        , category
        , signature_type
        , record_status
        , previous_submit_status
        , bank_scope
        , allow_import
        , late_submission_days
        , submission_deadline
        , requires_disclosure
        , event_type_id
        , event_date
        , document_date
        , sent_at
        , cancelled_at
        , sender_id
        , cancelled_by
        , import_file_path
        , created_at
    FROM {{ ref('ods_scms_sc_firm_adhoc_report') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_ADHOC_REPORT', "sc_fi_ad_re.id") }}                              AS sc_adhoc_rpt_id
    , CAST(sc_fi_ad_re.id AS string)                                                                                AS sc_adhoc_rpt_code
    , CAST('SCMS_SC_FIRM_ADHOC_REPORT' AS string)                                                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                                     AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                                 AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "sc_fi_ad_re.sc_firm_foreign_branch_id") }}   AS sc_foreign_branch_id
    , CAST(sc_fi_ad_re.sc_firm_foreign_branch_id AS string)                                                         AS sc_foreign_branch_code
    , {{ generate_surrogate_key_bigint('SCMS_BANK', "sc_fi_ad_re.bank_id") }}                                       AS sc_bank_id
    , CAST(sc_fi_ad_re.bank_id AS string)                                                                           AS sc_bank_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "sc_fi_ad_re.form_report_id") }}                         AS sc_rpt_id
    , CAST(sc_fi_ad_re.form_report_id AS string)                                                                    AS sc_rpt_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "sc_fi_ad_re.form_version_id") }}                        AS submitted_sc_rpt_id
    , CAST(sc_fi_ad_re.form_version_id AS string)                                                                   AS submitted_sc_rpt_code
    , {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_SUBMISSION', "sc_fi_ad_re.report_input_submission_id") }} AS sc_rpt_input_submission_id
    , CAST(sc_fi_ad_re.report_input_submission_id AS string)                                                        AS sc_rpt_input_submission_code
    , CAST(sc_fi_ad_re.report_name AS string)                                                                       AS rpt_nm
    , CAST(sc_fi_ad_re.report_year AS int)                                                                          AS rpt_year
    , CAST(sc_fi_ad_re.document_number AS string)                                                                   AS document_nbr
    , CAST(sc_fi_ad_re.period_value AS string)                                                                      AS period_val
    , CAST(sc_fi_ad_re.detail_type AS string)                                                                       AS adhoc_rpt_code
    , CAST(sc_fi_ad_re.category AS string)                                                                          AS category_code
    , CAST(sc_fi_ad_re.signature_type AS string)                                                                    AS signature_tp_code
    , CAST(sc_fi_ad_re.record_status AS string)                                                                     AS rpt_submission_status_code
    , CAST(sc_fi_ad_re.previous_submit_status AS int)                                                               AS previous_rpt_submission_status_code
    , CAST(sc_fi_ad_re.bank_scope AS string)                                                                        AS depositary_bank_scope_code
    , CAST(sc_fi_ad_re.allow_import AS int)                                                                         AS allow_import_ind
    , CAST(sc_fi_ad_re.late_submission_days AS int)                                                                 AS overdue_days
    , CAST(sc_fi_ad_re.submission_deadline AS timestamp)                                                            AS submission_deadline_tms
    , CAST(sc_fi_ad_re.requires_disclosure AS int)                                                                  AS requires_disclosure_ind
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "sc_fi_ad_re.event_type_id") }}                       AS cl_sc_event_tp_id
    , CAST(sc_fi_ad_re.event_type_id AS string)                                                                     AS cl_sc_event_tp_code
    , CAST(sc_fi_ad_re.event_date AS date)                                                                          AS event_dt
    , CAST(sc_fi_ad_re.document_date AS date)                                                                       AS document_dt
    , CAST(sc_fi_ad_re.sent_at AS timestamp)                                                                        AS sent_tms
    , CAST(sc_fi_ad_re.cancelled_at AS timestamp)                                                                   AS cancelled_tms
    , {{ generate_surrogate_key_bigint('IAM_USERS', "sc_fi_ad_re.sender_id") }}                                     AS sender_iam_user_id
    , CAST(sc_fi_ad_re.sender_id AS string)                                                                         AS sender_iam_user_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "sc_fi_ad_re.cancelled_by") }}                                  AS cancelled_by_iam_user_id
    , CAST(sc_fi_ad_re.cancelled_by AS string)                                                                      AS cancelled_by_iam_user_code
    , CAST(sc_fi_ad_re.import_file_path AS string)                                                                  AS import_file_path
    , CAST(sc_fi_ad_re.created_at AS date)                                                                          AS src_rcrd_isrt_tms
FROM sc_fi_ad_re
    LEFT JOIN sc_fi_in ON sc_fi_ad_re.sc_firm_info_id = sc_fi_in.id