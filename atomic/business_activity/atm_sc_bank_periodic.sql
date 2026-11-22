/*
*--------------------------------------------------------------------*
* Program code: atm_sc_bank_periodic
* Program name: Atomic Securities Company Bank Periodic
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_BANK_PERIODIC_REPORT.yaml (23 cot, Relative/scd2); khoi phuc khung tu git 77a9749^ va doi chieu LLD (cl_sc_event_tp_code = EVENT_TYPE_ID nguon theo source_columns LLD, khong join cat_event_type)
* 2026-11-13		claude		[MOI] Noi kieu theo nguon: rpt_year, period, quarter, rpt_month, overdue_days int->bigint (nguon NUMBER(10,0))
* 2026-11-14		claude		[Fix] cl_sc_event_tp_id = hash(SCMS_CAT_EVENT_TYPE, EVENT_TYPE_CODE) theo LLD/DM moi; cl_sc_event_tp_code = CAT_EVENT_TYPE.EVENT_TYPE_CODE lay qua join ods_scms_cat_event_type (event_type_id = id) -- thay cho EVENT_TYPE_ID nguon
*--------------------------------------------------------------------*
*/

WITH ca_ev_ty AS (
    SELECT
        id
        , event_type_code
    FROM {{ ref('ods_scms_cat_event_type') }}
),

ba_pe_re AS (
    SELECT
        id
        , bank_id
        , form_report_id
        , event_type_id
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
        , overdue_days
        , valid_digital_signature
        , valid_data
        , note
    FROM {{ ref('ods_scms_bank_periodic_report') }}
),

ca_ev_ty AS (
    SELECT
        id
        , event_type_code
    FROM {{ ref('ods_scms_cat_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK_PERIODIC_REPORT', "ba_pe_re.id") }}        AS sc_bank_periodic_id
    , CAST(ba_pe_re.id AS string)                                                          AS sc_bank_periodic_code
    , CAST('SCMS_BANK_PERIODIC_REPORT' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_BANK', "ba_pe_re.bank_id") }}                 AS sc_bank_id
    , CAST(ba_pe_re.bank_id AS string)                                                     AS sc_bank_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "ba_pe_re.form_report_id") }}   AS sc_rpt_id
    , CAST(ba_pe_re.form_report_id AS string)                                              AS sc_rpt_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "ca_ev_ty.event_type_code") }} AS cl_sc_event_tp_id
    , CAST(ca_ev_ty.event_type_code AS string)                                             AS cl_sc_event_tp_code
    , CAST(ba_pe_re.report_name AS string)                                                 AS rpt_nm
    , CAST(ba_pe_re.report_year AS int)                                                    AS rpt_year
    , CAST(ba_pe_re.period AS int)                                                         AS period
    , CAST(ba_pe_re.quarter AS int)                                                        AS quarter
    , CAST(ba_pe_re.report_month AS int)                                                   AS rpt_month
    , CAST(ba_pe_re.report_period AS string)                                               AS rpt_period
    , CAST(ba_pe_re.start_date AS date)                                                    AS start_dt
    , CAST(ba_pe_re.end_date AS date)                                                      AS end_dt
    , CAST(ba_pe_re.submission_deadline AS date)                                           AS submission_deadline_dt
    , CAST(ba_pe_re.submission_deadline_at AS timestamp)                                   AS submission_deadline_tms
    , CAST(ba_pe_re.overdue_days AS int)                                                   AS overdue_days
    , CAST(ba_pe_re.valid_digital_signature AS int)                                        AS valid_digital_signature_ind
    , CAST(ba_pe_re.valid_data AS int)                                                     AS valid_data_ind
    , CAST(ba_pe_re.note AS string)                                                        AS note
FROM ba_pe_re
    LEFT JOIN ca_ev_ty ON ba_pe_re.event_type_id = ca_ev_ty.id
    LEFT JOIN ca_ev_ty ON ba_pe_re.event_type_id = ca_ev_ty.id