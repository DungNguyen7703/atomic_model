/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_fund_management_organization_unit_dim
* Program name: Dtm Foreign Fund Management Organization Unit Dim
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c (luật A23 PK Dim): foreign_fund_management_organization_unit_id lấy trực tiếp foreign_fm_ou.foreign_fm_ou_id (Atomic) thay cho
*                                       generate_surrogate_key_bigint — khớp FK foreign_fund_management_organization_unit_id mà các model khác đọc từ Atomic (logic-only, schema không đổi)
*--------------------------------------------------------------------*
*/

WITH foreign_fm_ou AS (
    SELECT
        foreign_fm_ou_id,
        foreign_fm_ou_code,
        foreign_fm_ou_full_nm,
        foreign_fm_ou_english_nm,
        foreign_fm_ou_short_nm,
        ou_tp_code,
        cl_fms_status_code,
        country_of_registration_id,
        country_of_registration_code,
        cl_fms_event_tp_id,
        cl_fms_event_tp_code,
        charter_capital_amt,
        parent_ou_nm,
        parent_ou_code,
        amendment_license_nbr,
        amendment_license_dt,
        amendment_note,
        note,
        effective_start_dt,
        effective_end_dt,
        src_stm_code
    FROM {{ ref('atm_foreign_fm_ou') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
)

SELECT
    CAST(foreign_fm_ou_id AS string)                                   AS foreign_fund_management_organization_unit_id,
    CAST(foreign_fm_ou_code AS string)                                 AS foreign_fund_management_organization_unit_code,
    CAST(foreign_fm_ou_full_nm AS string)                              AS foreign_fund_management_organization_unit_full_nm,
    CAST(foreign_fm_ou_english_nm AS string)                           AS foreign_fund_management_organization_unit_english_nm,
    CAST(foreign_fm_ou_short_nm AS string)                             AS foreign_fund_management_organization_unit_short_nm,
    CAST(ou_tp_code AS string)                                         AS branch_tp_code,
    CAST(cl_fms_status_code AS string)                                 AS operation_status_code,
    CAST(country_of_registration_id AS string)                         AS country_of_registration_id,
    CAST(country_of_registration_code AS string)                       AS country_of_registration_code,
    CAST(cl_fms_event_tp_id AS string)                                 AS event_tp_id,
    CAST(cl_fms_event_tp_code AS string)                               AS event_tp_code,
    CAST(charter_capital_amt AS decimal(23,2))                         AS charter_capital_amt,
    CAST(parent_ou_nm AS string)                                       AS parent_company_nm,
    CAST(parent_ou_code AS string)                                     AS parent_company_code,
    CAST(amendment_license_nbr AS string)                              AS amendment_license_nbr,
    CAST(amendment_license_dt AS date)                                 AS amendment_license_dt,
    CAST(amendment_note AS string)                                     AS amendment_note,
    CAST(note AS string)                                               AS note,
    CAST(effective_start_dt AS date)                                   AS effective_start_dt,
    CAST(effective_end_dt AS date)                                     AS effective_end_dt,
    CAST(src_stm_code AS string)                                       AS src_stm_code
FROM foreign_fm_ou
