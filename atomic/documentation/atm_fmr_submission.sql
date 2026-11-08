/*
*--------------------------------------------------------------------*
* Program code: atm_fmr_submission
* Program name: Atomic Fund Management Report Submission
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo theo thiết kế dm_atm_fmr_submission-FMS.RPT_MEMBER.yaml
*										report_type/record_type/period_type decimal -> int -> string; year_value decimal -> int
* 2026-10-24		claude				Bổ sung information_disclosure_dt (CBTT_DATE), record_status_code (RECORD_STATUS) theo thiết kế
*--------------------------------------------------------------------*
*/

WITH rp_me AS (
    SELECT
        id
        , prd_id
        , rpt_id
        , rpt_name
        , report_type
        , imported
        , date_submitted
        , bkm_id
        , fnd_id
        , fr_br_id
        , sec_id
        , record_type
        , day_report
        , period_value
        , year_value
        , period_type
        , distributor_id
        , member_name
        , event_type_id
        , deadline_send
        , cbtt_date
        , record_status
    FROM {{ ref('ods_fms_rpt_member') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_RPT_MEMBER', "id") }}                      AS fmr_submission_id
    , CAST(id AS string)                                                             AS fmr_submission_code
    , CAST('FMS_RPT_MEMBER' AS string)                                               AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_RPT_PERIOD', "prd_id") }}                AS fmr_period_id
    , CAST(prd_id AS string)                                                         AS fmr_period_code
    , {{ generate_surrogate_key_bigint('FMS_RPT_TEMP', "rpt_id") }}                  AS fmr_id
    , CAST(rpt_id AS string)                                                         AS fmr_code
    , CAST(rpt_name AS string)                                                       AS rpt_nm
    , CAST(CAST(report_type AS int) AS string)                                       AS rpt_tp_code
    , CAST(imported AS int)                                                          AS imported_ind
    , CAST(date_submitted AS date)                                                   AS submitted_dt
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "bkm_id") }}                 AS custodian_bank_id
    , CAST(bkm_id AS string)                                                         AS custodian_bank_code
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "fnd_id") }}                     AS investment_fund_id
    , CAST(fnd_id AS string)                                                         AS investment_fund_code
    , {{ generate_surrogate_key_bigint('FMS_FOR_BRCH', "fr_br_id") }}                AS foreign_fm_ou_id
    , CAST(fr_br_id AS string)                                                       AS foreign_fm_ou_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "sec_id") }}                AS fmc_id
    , CAST(sec_id AS string)                                                         AS fmc_code
    , CAST(CAST(record_type AS int) AS string)                                       AS record_tp
    , CAST(day_report AS date)                                                       AS rpt_dt
    , CAST(period_value AS string)                                                   AS period_val
    , CAST(year_value AS int)                                                        AS rpt_year
    , CAST(CAST(period_type AS int) AS string)                                       AS period_tp_code
    , {{ generate_surrogate_key_bigint('FMS_DISTRIBUTOR_AGENT', "distributor_id") }} AS securities_distribution_agent_id
    , CAST(distributor_id AS string)                                                 AS securities_distribution_agent_code
    , CAST(member_name AS string)                                                    AS member_nm
    , {{ generate_surrogate_key_bigint('FMS_EVENT_TYPE', "event_type_id") }}         AS cl_fms_event_tp_id
    , CAST(event_type_id AS string)                                                  AS cl_fms_event_tp_code
    , CAST(deadline_send AS timestamp)                                               AS submission_deadline_tms
    , CAST(cbtt_date AS date)                                                        AS information_disclosure_dt
    , CAST(record_status AS string)                                                  AS record_status_code
FROM rp_me
