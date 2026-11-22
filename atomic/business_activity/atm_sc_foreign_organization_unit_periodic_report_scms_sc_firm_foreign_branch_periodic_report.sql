/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_organization_unit_periodic_report
* Program name: Atomic Securities Company Foreign Organization Unit Periodic Report SCMS.SC_FIRM_FOREIGN_BRANCH_PERIODIC_REPORT
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH_PERIODIC_REPORT.yaml (nguon con cua multi source, khoi phuc tu git 77a9749^ va doi chieu LLD: dung 27 cot, dung thu tu).
*									[MOI] noi kieu report_year -> rpt_year, period -> period sang bigint theo nguon (branch ODS bigint NUMBER(10,0)); rep_office ODS int nhung CAST bigint de dong bo cot vat ly entity chung (LLD/DM: int).
* 2026-11-14		claude		[Fix] cl_sc_event_tp_id = hash(SCMS_CAT_EVENT_TYPE, EVENT_TYPE_CODE) theo LLD/DM moi; cl_sc_event_tp_code = CAT_EVENT_TYPE.EVENT_TYPE_CODE lay qua join ods_scms_cat_event_type (event_type_id = id)
*--------------------------------------------------------------------*
*/

WITH ca_ev_ty AS (
    SELECT
        id AS ca_ev_ty_id
        , event_type_code AS ca_ev_ty_code
    FROM {{ ref('ods_scms_cat_event_type') }}
),

sc_fo_br_pe_re AS (
    SELECT
        id
        , sc_firm_foreign_branch_id
        , event_type_id
        , report_name
        , category
        , report_period
        , report_year
        , period
        , quarter
        , report_month
        , start_date
        , end_date
        , summary
        , eform_data
        , note
        , document_number
        , document_date
        , event_date
        , import_file_path
        , submission_deadline
        , submission_deadline_at
        , sent_at
        , previous_submit_status
    FROM {{ ref('ods_scms_sc_firm_foreign_branch_periodic_report') }}
),

ca_ev_ty AS (
    SELECT
        id
        , event_type_code
    FROM {{ ref('ods_scms_cat_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH_PERIODIC_REPORT', "sc_fo_br_pe_re.id") }}            AS sc_foreign_ou_periodic_rpt_id
    , CAST(sc_fo_br_pe_re.id AS string)                                                                                AS sc_foreign_ou_periodic_rpt_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH_PERIODIC_REPORT' AS string)                                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "sc_fo_br_pe_re.sc_firm_foreign_branch_id") }}   AS sc_foreign_ou_id
    , CAST(sc_fo_br_pe_re.sc_firm_foreign_branch_id AS string)                                                         AS sc_foreign_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "ca_ev_ty.event_type_code") }}                           AS cl_sc_event_tp_id
    , CAST(ca_ev_ty.event_type_code AS string)                                                                         AS cl_sc_event_tp_code
    , CAST(sc_fo_br_pe_re.report_name AS string)                                                                       AS rpt_nm
    , CAST(sc_fo_br_pe_re.category AS string)                                                                          AS category
    , CAST(sc_fo_br_pe_re.report_period AS string)                                                                     AS rpt_period
    , CAST(sc_fo_br_pe_re.report_year AS int)                                                                          AS rpt_year
    , CAST(sc_fo_br_pe_re.period AS int)                                                                               AS period
    , CAST(sc_fo_br_pe_re.quarter AS int)                                                                              AS quarter
    , CAST(sc_fo_br_pe_re.report_month AS int)                                                                         AS rpt_month
    , CAST(sc_fo_br_pe_re.start_date AS date)                                                                          AS start_dt
    , CAST(sc_fo_br_pe_re.end_date AS date)                                                                            AS end_dt
    , CAST(sc_fo_br_pe_re.summary AS string)                                                                           AS summary
    , CAST(sc_fo_br_pe_re.eform_data AS string)                                                                        AS eform_data
    , CAST(sc_fo_br_pe_re.note AS string)                                                                              AS note
    , CAST(sc_fo_br_pe_re.document_number AS string)                                                                   AS document_nbr
    , CAST(sc_fo_br_pe_re.document_date AS date)                                                                       AS document_dt
    , CAST(sc_fo_br_pe_re.event_date AS date)                                                                          AS event_dt
    , CAST(sc_fo_br_pe_re.import_file_path AS string)                                                                  AS import_file_path
    , CAST(sc_fo_br_pe_re.submission_deadline AS date)                                                                 AS submission_deadline_dt
    , CAST(sc_fo_br_pe_re.submission_deadline_at AS timestamp)                                                         AS submission_deadline_tms
    , CAST(sc_fo_br_pe_re.sent_at AS timestamp)                                                                        AS sent_tms
    , CAST(sc_fo_br_pe_re.previous_submit_status AS int)                                                               AS previous_rpt_submission_status_code
FROM sc_fo_br_pe_re
    LEFT JOIN ca_ev_ty ON sc_fo_br_pe_re.event_type_id = ca_ev_ty.id
