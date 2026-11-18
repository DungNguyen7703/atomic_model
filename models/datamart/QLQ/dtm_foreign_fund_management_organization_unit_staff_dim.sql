/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_fund_management_organization_unit_staff_dim
* Program name: Dtm Foreign Fund Management Organization Unit Staff Dim
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_foreign_fund_management_organization_unit_staff_dim_FMS_STF_FG_BRCH.csv
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): đọc cl_fms_job_code, legal_representative_ind,
*                                       branch_director_ind; BỎ cột active_status_flag, operating_license_nbr, operating_license_dt (schema-changing)
*--------------------------------------------------------------------*
*/

WITH foreign_fm_ou_staff AS (
    SELECT
        foreign_fm_ou_staff_code,
        foreign_fm_ou_id,
        foreign_fm_ou_code,
        foreign_fm_ou_staff_full_nm,
        cl_fms_job_code,
        staff_branch_tp_code,
        gender_code,
        legal_representative_ind,
        held_unit_quantity,
        branch_director_ind,
        director_appointment_license_nbr,
        director_appointment_approval_dt,
        src_stm_code
    FROM {{ ref('atm_foreign_fm_ou_staff') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_STF_FG_BRCH'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FMS_STF_FG_BRCH', 'foreign_fm_ou_staff_code') }} AS string) AS foreign_fund_management_organization_unit_staff_id,
    CAST(foreign_fm_ou_staff_code AS string)                     AS foreign_fund_management_organization_unit_staff_code,
    CAST(foreign_fm_ou_id AS string)                             AS foreign_fund_management_organization_unit_id,
    CAST(foreign_fm_ou_code AS string)                           AS foreign_fund_management_organization_unit_code,
    CAST(foreign_fm_ou_staff_full_nm AS string)                  AS foreign_fund_management_organization_unit_staff_full_nm,
    CAST(cl_fms_job_code AS string)                              AS job_title_code,
    CAST(staff_branch_tp_code AS string)                         AS staff_branch_tp_code,
    CAST(gender_code AS string)                                  AS gender_code,
    CAST(legal_representative_ind AS int)                        AS legal_representative_flag,
    CAST(held_unit_quantity AS int)                              AS held_unit_quantity,
    CAST(branch_director_ind AS int)                             AS branch_director_flag,
    CAST(director_appointment_license_nbr AS string)             AS director_appointment_license_nbr,
    CAST(director_appointment_approval_dt AS date)               AS director_appointment_approval_dt,
    CAST(src_stm_code AS string)                                 AS src_stm_code
FROM foreign_fm_ou_staff
