/*
*--------------------------------------------------------------------*
* Program code: atm_sc_practitioner
* Program name: Atomic Securities Company Practitioner
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_LICENSED_PRACTITIONER.yaml (30 cot, Fundamental/scd4a); sc_id/sc_code lay tu SC_FIRM_INFO.CODE (join sc_firm_info_id = sc_fi_in.id); nationality_id crosswalk CAT_NATIONALITY.NATIONALITY_CODE -> hash ECAT_COUNTRY
* 2026-11-13		claude		[MOI] Noi kieu theo nguon: verification_status_code, business_division_id, responsible_service_id, insider_ind, rpt_id int->bigint (nguon NUMBER(10,0)/NUMBER)
* 2026-11-13		claude		[MOI] licensed_service_codes: LLD/DM data_type string (list SERVICE_ID dang CSV VARCHAR2(100)), giu CAST string - khong tach mang
*--------------------------------------------------------------------*
*/

WITH sc_fi_li_pr AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_branch_id
        , sc_firm_transaction_office_id
        , sc_firm_rep_office_id
        , nationality_id
        , securities_license_number
        , securities_license_date
        , work_status
        , verification_status
        , work_start_date
        , work_end_date
        , appointment_date
        , dismissal_date
        , issue_date
        , business_line_id
        , business_division_id
        , responsible_service_id
        , latest_verification_at
        , insider
        , labor_contract_termination_report
        , report_id
        , note
    FROM {{ ref('ods_scms_sc_firm_licensed_practitioner') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_na AS (
    SELECT
        id
        , nationality_code
    FROM {{ ref('ods_scms_cat_nationality') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_LICENSED_PRACTITIONER', "sc_fi_li_pr.id") }}                           AS sc_practitioner_id
    , CAST(sc_fi_li_pr.id AS string)                                                                                      AS sc_practitioner_code
    , CAST('SCMS_SC_FIRM_LICENSED_PRACTITIONER' AS string)                                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                                           AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                                       AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_li_pr.sc_firm_branch_id") }}                         AS branch_ou_id
    , CAST(sc_fi_li_pr.sc_firm_branch_id AS string)                                                                       AS branch_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_TRANSACTION_OFFICE', "sc_fi_li_pr.sc_firm_transaction_office_id") }} AS transaction_office_ou_id
    , CAST(sc_fi_li_pr.sc_firm_transaction_office_id AS string)                                                           AS transaction_office_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_REP_OFFICE', "sc_fi_li_pr.sc_firm_rep_office_id") }}                 AS representative_office_ou_id
    , CAST(sc_fi_li_pr.sc_firm_rep_office_id AS string)                                                                   AS representative_office_ou_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}                                       AS nationality_id
    , CAST(ca_na.nationality_code AS string)                                                                              AS nationality_code
    , CAST(sc_fi_li_pr.securities_license_number AS string)                                                               AS securities_license_nbr
    , CAST(sc_fi_li_pr.securities_license_date AS date)                                                                   AS securities_license_dt
    , CAST(sc_fi_li_pr.work_status AS string)                                                                             AS work_status_code
    , CAST(sc_fi_li_pr.verification_status AS int)                                                                        AS verification_status_code
    , CAST(sc_fi_li_pr.work_start_date AS date)                                                                           AS work_start_dt
    , CAST(sc_fi_li_pr.work_end_date AS date)                                                                             AS work_end_dt
    , CAST(sc_fi_li_pr.appointment_date AS date)                                                                          AS appointment_dt
    , CAST(sc_fi_li_pr.dismissal_date AS date)                                                                            AS dismissal_dt
    , CAST(sc_fi_li_pr.issue_date AS date)                                                                                AS certificate_issue_dt
    , CAST(sc_fi_li_pr.business_line_id AS string)                                                                        AS licensed_service_codes
    , CAST(sc_fi_li_pr.business_division_id AS int)                                                                       AS business_division_id
    , CAST(sc_fi_li_pr.responsible_service_id AS int)                                                                     AS responsible_service_id
    , CAST(sc_fi_li_pr.latest_verification_at AS timestamp)                                                               AS latest_verification_tms
    , CAST(sc_fi_li_pr.insider AS int)                                                                                    AS insider_ind
    , CAST(sc_fi_li_pr.labor_contract_termination_report AS int)                                                          AS labor_contract_termination_rpt_ind
    , CAST(sc_fi_li_pr.report_id AS int)                                                                                  AS rpt_id
    , CAST(sc_fi_li_pr.note AS string)                                                                                    AS note
FROM sc_fi_li_pr
    LEFT JOIN sc_fi_in ON sc_fi_li_pr.sc_firm_info_id = sc_fi_in.id
    LEFT JOIN ca_na ON sc_fi_li_pr.nationality_id = ca_na.id