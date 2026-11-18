/*
*--------------------------------------------------------------------*
* Program code: atm_fmc_employee
* Program name: Atomic Fund Management Company Employee
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khoi tao theo LLD Atomic FMS UAT 20261006 (lld_FMS_TL_PROFILES.yaml)
*										cl_fms_event_tp_* qua crosswalk TL_PROFILES.EVENT_TYPE_ID = EVENT_TYPE.ID (lay EVENT_CODE);
*										employment_active_ind = CASE EMPLOYED Y/N; internal_identification_ind giu string theo LLD
*--------------------------------------------------------------------*
*/

WITH tl_pr AS (
    SELECT
        id
        , sec_id
        , branch_id
        , item_name
        , short_name
        , sex
        , qtty
        , description
        , cust_type
        , jobfr_date
        , jobclose_date
        , isr
        , education
        , qualyfication
        , job_type
        , politics
        , birth
        , place_of_birth
        , cert_type
        , isd
        , isi
        , host_office
        , record_type
        , mov_date
        , employed
        , posit_job
        , time_work
        , profession
        , cdy_acc
        , swork_dte
        , fwork_dte
        , fn_type
        , department
        , insder_id
        , busi_id
        , confirm_status
        , event_type_id
        , edit_reason
        , certified
    FROM {{ ref('ods_fms_tl_profiles') }}
),

ev_ty AS (
    SELECT
        id
        , event_code
    FROM {{ ref('ods_fms_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_TL_PROFILES', "tl_pr.id") }}                     AS fmc_employee_id
    , CAST(tl_pr.id AS string)                                                             AS fmc_employee_code
    , CAST('FMS_TL_PROFILES' AS string)                                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "tl_pr.sec_id") }}                AS fmc_id
    , CAST(tl_pr.sec_id AS string)                                                         AS fmc_code
    , {{ generate_surrogate_key_bigint('FMS_BRANCHS', "tl_pr.branch_id") }}                AS fmc_ou_id
    , CAST(tl_pr.branch_id AS string)                                                      AS fmc_ou_code
    , CAST(tl_pr.item_name AS string)                                                      AS fmc_employee_full_nm
    , CAST(tl_pr.short_name AS string)                                                     AS fmc_employee_short_nm
    , CAST(tl_pr.sex AS string)                                                            AS gender_code
    , CAST(tl_pr.qtty AS int)                                                              AS held_unit_quantity
    , CAST(tl_pr.description AS string)                                                    AS description
    , CAST(tl_pr.cust_type AS string)                                                      AS custom_personnel_tp_description
    , CAST(tl_pr.jobfr_date AS date)                                                       AS practice_start_dt
    , CAST(tl_pr.jobclose_date AS date)                                                    AS practice_end_dt
    , CAST(tl_pr.isr AS decimal(5,2))                                                      AS held_share_percentage
    , CAST(tl_pr.education AS string)                                                      AS education_level_nm
    , CAST(tl_pr.qualyfication AS string)                                                  AS professional_qualification_nm
    , CAST(tl_pr.job_type AS string)                                                       AS certificate_tp_code
    , CAST(tl_pr.politics AS int)                                                          AS political_information_ind
    , CAST(tl_pr.birth AS date)                                                            AS birth_dt
    , CAST(tl_pr.place_of_birth AS string)                                                 AS birth_place
    , CAST(tl_pr.cert_type AS string)                                                      AS certificate_tp_description
    , CAST(tl_pr.isd AS string)                                                            AS related_security_code
    , CAST(tl_pr.isi AS string)                                                            AS internal_identification_ind
    , CAST(tl_pr.host_office AS int)                                                       AS head_office_ind
    , CAST(tl_pr.record_type AS string)                                                    AS record_cl_text
    , CAST(tl_pr.mov_date AS date)                                                         AS transfer_dt
    , CAST(CASE WHEN tl_pr.employed = 'Y' THEN 1 WHEN tl_pr.employed = 'N' THEN 0 END AS int) AS employment_active_ind
    , CAST(tl_pr.posit_job AS string)                                                      AS current_position_title
    , CAST(tl_pr.time_work AS string)                                                      AS work_experience_description
    , CAST(tl_pr.profession AS string)                                                     AS profession_description
    , CAST(tl_pr.cdy_acc AS string)                                                        AS securities_trading_account_nbr
    , CAST(tl_pr.swork_dte AS date)                                                        AS current_employment_start_dt
    , CAST(tl_pr.fwork_dte AS date)                                                        AS current_employment_end_dt
    , CAST(tl_pr.fn_type AS string)                                                        AS function_tp_description
    , CAST(tl_pr.department AS string)                                                     AS department_nm
    , {{ generate_surrogate_key_bigint('FMS_INSIDER', "tl_pr.insder_id") }}                AS fmc_insider_id
    , CAST(tl_pr.insder_id AS string)                                                      AS fmc_insider_code
    , {{ generate_surrogate_key_bigint('FMS_BUSINESS', "tl_pr.busi_id") }}                 AS cl_fms_business_id
    , CAST(tl_pr.busi_id AS string)                                                        AS cl_fms_business_code
    , CAST(tl_pr.confirm_status AS int)                                                    AS confirmation_status_ind
    , {{ generate_surrogate_key_bigint('FMS_EVENT_TYPE', "ev_ty.event_code") }}            AS cl_fms_event_tp_id
    , CAST(ev_ty.event_code AS string)                                                     AS cl_fms_event_tp_code
    , CAST(tl_pr.edit_reason AS string)                                                    AS edit_reason_description
    , CAST(tl_pr.certified AS int)                                                         AS certified_practitioner_ind
FROM tl_pr
    LEFT JOIN ev_ty ON tl_pr.event_type_id = ev_ty.id