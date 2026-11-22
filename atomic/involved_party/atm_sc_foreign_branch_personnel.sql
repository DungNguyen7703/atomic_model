/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_branch_personnel
* Program name: Atomic Securities Company Foreign Branch Personnel
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL.yaml (27 cot, Fundamental/scd4a); khoi phuc tu git 77a9749^, doi chieu LLD khop thu tu/ten cot; data_dt = CAST(created_at AS date) theo LLD
*--------------------------------------------------------------------*
*/

WITH fo_br_pe AS (
    SELECT
        id
        , created_at
        , sc_firm_foreign_branch_id
        , full_name
        , gender
        , date_of_birth
        , nationality
        , business_division
        , department
        , position_json
        , branch_head_user_id
        , disclosure_representative
        , work_start_date
        , appointment_date
        , dismissal_date
        , resignation_date
        , securities_license
        , securities_license_number
        , securities_license_date
        , verification_status
        , record_status
        , work_status
        , attachment_path
        , note
    FROM {{ ref('ods_scms_sc_firm_foreign_branch_personnel') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL', "fo_br_pe.id") }}                AS sc_foreign_branch_personnel_id
    , CAST(fo_br_pe.id AS string)                                                                              AS sc_foreign_branch_personnel_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL' AS string)                                                  AS src_stm_code
    , CAST(fo_br_pe.created_at AS date)                                                                        AS data_dt
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "fo_br_pe.sc_firm_foreign_branch_id") }} AS sc_foreign_ou_id
    , CAST(fo_br_pe.sc_firm_foreign_branch_id AS string)                                                       AS sc_foreign_ou_code
    , CAST(fo_br_pe.full_name AS string)                                                                       AS full_nm
    , CAST(fo_br_pe.gender AS string)                                                                          AS gender_code
    , CAST(fo_br_pe.date_of_birth AS date)                                                                     AS dt_of_birth
    , CAST(fo_br_pe.nationality AS string)                                                                     AS nationality
    , CAST(fo_br_pe.business_division AS string)                                                               AS business_division_nm
    , CAST(fo_br_pe.department AS string)                                                                      AS department
    , CAST(fo_br_pe.position_json AS string)                                                                   AS position_json
    , CAST(fo_br_pe.branch_head_user_id AS int)                                                                AS branch_head_ind
    , CAST(fo_br_pe.disclosure_representative AS int)                                                          AS disclosure_representative_ind
    , CAST(fo_br_pe.work_start_date AS date)                                                                   AS work_start_dt
    , CAST(fo_br_pe.appointment_date AS date)                                                                  AS appointment_dt
    , CAST(fo_br_pe.dismissal_date AS date)                                                                    AS dismissal_dt
    , CAST(fo_br_pe.resignation_date AS date)                                                                  AS resignation_dt
    , CAST(fo_br_pe.securities_license AS int)                                                                 AS securities_license_ind
    , CAST(fo_br_pe.securities_license_number AS string)                                                       AS securities_license_nbr
    , CAST(fo_br_pe.securities_license_date AS date)                                                           AS securities_license_dt
    , CAST(fo_br_pe.verification_status AS string)                                                             AS verification_status_code
    , CAST(fo_br_pe.record_status AS string)                                                                   AS record_status_code
    , CAST(fo_br_pe.work_status AS string)                                                                     AS work_status_code
    , CAST(fo_br_pe.attachment_path AS string)                                                                 AS attachment_path
    , CAST(fo_br_pe.note AS string)                                                                            AS note
FROM fo_br_pe