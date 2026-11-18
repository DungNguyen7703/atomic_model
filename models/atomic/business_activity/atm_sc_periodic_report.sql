/*
*--------------------------------------------------------------------*
* Program code: atm_sc_periodic_report
* Program name: Atomic Securities Company Periodic Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_pe_re AS (
    SELECT
        id
        , sc_firm_info_id
        , form_report_id
        , report_name
        , report_year
        , period
        , quarter
        , report_month
        , report_period
        , start_date
        , end_date
        , submission_deadline
        , submission_deadline_at
        , record_status
        , overdue_days
        , event_type_id
        , sent_at
        , valid_digital_signature
        , valid_data
        , previous_submit_status
    FROM {{ ref('ods_scms_sc_firm_periodic_report') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_PERIODIC_REPORT', "sc_fi_pe_re.id") }}     AS sc_periodic_rpt_id
    , CAST(sc_fi_pe_re.id AS string)                                                          AS sc_periodic_rpt_code
    , CAST('SCMS_SC_FIRM_PERIODIC_REPORT' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}               AS sc_id
    , CAST(sc_fi_in.code AS string)                                                           AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "sc_fi_pe_re.form_report_id") }}   AS sc_form_rpt_id
    , CAST(sc_fi_pe_re.form_report_id AS string)                                              AS sc_form_rpt_code
    , CAST(sc_fi_pe_re.report_name AS string)                                                 AS rpt_nm
    , CAST(sc_fi_pe_re.report_year AS int)                                                    AS rpt_year
    , CAST(sc_fi_pe_re.period AS int)                                                         AS period
    , CAST(sc_fi_pe_re.quarter AS int)                                                        AS quarter
    , CAST(sc_fi_pe_re.report_month AS int)                                                   AS rpt_month
    , CAST(sc_fi_pe_re.report_period AS string)                                               AS rpt_period
    , CAST(sc_fi_pe_re.start_date AS date)                                                    AS start_dt
    , CAST(sc_fi_pe_re.end_date AS date)                                                      AS end_dt
    , CAST(sc_fi_pe_re.submission_deadline AS date)                                           AS submission_deadline_dt
    , CAST(sc_fi_pe_re.submission_deadline_at AS timestamp)                                   AS submission_deadline_tms
    , CAST(sc_fi_pe_re.record_status AS string)                                               AS rpt_submission_status_code
    , CAST(sc_fi_pe_re.overdue_days AS int)                                                   AS overdue_days
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "sc_fi_pe_re.event_type_id") }} AS cl_sc_event_tp_id
    , CAST(sc_fi_pe_re.event_type_id AS string)                                               AS cl_sc_event_tp_code
    , CAST(sc_fi_pe_re.sent_at AS timestamp)                                                  AS sent_tms
    , CAST(sc_fi_pe_re.valid_digital_signature AS int)                                        AS valid_digital_signature_ind
    , CAST(sc_fi_pe_re.valid_data AS int)                                                     AS valid_data_ind
    , CAST(sc_fi_pe_re.previous_submit_status AS int)                                         AS previous_rpt_submission_status_code
FROM sc_fi_pe_re
    LEFT JOIN sc_fi_in ON sc_fi_pe_re.sc_firm_info_id = sc_fi_in.id