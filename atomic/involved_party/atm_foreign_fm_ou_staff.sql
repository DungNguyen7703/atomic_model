/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_fm_ou_staff
* Program name: Atomic Foreign Fund Management Organization Unit Staff
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Sync LLD Atomic FMS UAT 20261006 (lld_FMS_STF_FG_BRCH.yaml): job_title_code -> cl_fms_job_id/code;
*										*_flag -> legal_representative_ind/branch_director_ind; bo active_status_flag,
*										operating_license_nbr/dt (LICENSE/LICENSE_DATE da map sang IP Alt Identification)
*--------------------------------------------------------------------*
*/

WITH st_fg_br AS (
    SELECT
        id
        , for_brch_id
        , jobs_id
        , nat_id
        , staff_branch
        , item_name
        , sex
        , represent
        , note
        , isp
        , branch_director
        , director_appoint_license_no
        , director_approval_date
    FROM {{ ref('ods_fms_stf_fg_brch') }}
),

nati AS (
    SELECT
        id
        , sname
    FROM {{ ref('ods_fms_national') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_STF_FG_BRCH', "st_fg_br.id") }}         AS foreign_fm_ou_staff_id
    , CAST(st_fg_br.id AS string)                                                 AS foreign_fm_ou_staff_code
    , CAST('FMS_STF_FG_BRCH' AS string)                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_FOR_BRCH', "st_fg_br.for_brch_id") }} AS foreign_fm_ou_id
    , CAST(st_fg_br.for_brch_id AS string)                                        AS foreign_fm_ou_code
    , {{ generate_surrogate_key_bigint('FMS_JOBS', "st_fg_br.jobs_id") }}         AS cl_fms_job_id
    , CAST(st_fg_br.jobs_id AS string)                                            AS cl_fms_job_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }}           AS nationality_id
    , CAST(nati.sname AS string)                                                  AS nationality_code
    , CAST(st_fg_br.staff_branch AS string)                                       AS staff_branch_tp_code
    , CAST(st_fg_br.item_name AS string)                                          AS foreign_fm_ou_staff_full_nm
    , CAST(st_fg_br.sex AS string)                                                AS gender_code
    , CAST(st_fg_br.represent AS int)                                             AS legal_representative_ind
    , CAST(st_fg_br.note AS string)                                               AS note
    , CAST(st_fg_br.isp AS int)                                                   AS held_unit_quantity
    , CAST(st_fg_br.branch_director AS int)                                       AS branch_director_ind
    , CAST(st_fg_br.director_appoint_license_no AS string)                        AS director_appointment_license_nbr
    , CAST(st_fg_br.director_approval_date AS date)                               AS director_appointment_approval_dt
FROM st_fg_br
    LEFT JOIN nati ON st_fg_br.NAT_ID = nati.ID