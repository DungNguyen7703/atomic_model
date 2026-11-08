/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_profile
* Program name: Dtm Opr Individual Profile
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH se_pr AS (
    SELECT 
        sp_id,
        sp_code, 
        full_nm, 
        position_nm, 
        src_stm_code
    FROM {{ ref('atm_securities_practitioner') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

ip_al_id_nhnck AS (
    SELECT
        ip_id,
        identification_nbr,
        src_stm_code
    FROM {{ ref('atm_ip_alternative_identification')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code IN ('NATIONAL_ID','CITIZEN_ID')
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

ip_al_id_scms AS (
    SELECT
        ip_id,
        identification_nbr,
        src_stm_code
    FROM {{ ref('atm_ip_alternative_identification')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'NATIONAL_ID'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

sc_se_pe AS (
    SELECT
        sc_senior_personnel_id,
        sc_senior_personnel_code,
        sc_code,
        full_nm,
        position_nm,
        appointment_dt,
        src_stm_code
    FROM {{ ref('atm_sc_senior_personnel') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

sp_li_ce_do AS (
    SELECT
        sp_id,
        sp_license_certificate_document_code
    FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND ds_rcrd_st = 'ACTIVE'
    AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
)

SELECT
    CAST(se_pr.sp_code AS string)      AS sc_senior_personnel_code,
    NULL                               AS sc_code,  -- PENDING
    CAST(se_pr.full_nm AS string)      AS full_nm,
    CAST(se_pr.position_nm AS string)  AS position_nm,
    ip_al_id_nhnck.identification_nbr  AS identification_nbr,
    sp_li_ce_do.sp_license_certificate_document_code AS license_certificate_nbr,
    NULL                               AS appointment_dt,  -- PENDING: khong ap dung cho NHNCK
    CAST(se_pr.src_stm_code AS string) AS src_stm_code
FROM se_pr
LEFT JOIN ip_al_id_nhnck ON se_pr.sp_id = ip_al_id_nhnck.ip_id
LEFT JOIN sp_li_ce_do ON se_pr.sp_id = sp_li_ce_do.sp_id

UNION ALL

SELECT
    CAST(sc_se_pe.sc_senior_personnel_code AS string) AS sc_senior_personnel_code,
    CAST(sc_se_pe.sc_code AS string)                  AS sc_code,
    CAST(sc_se_pe.full_nm AS string)                  AS full_nm,
    CAST(sc_se_pe.position_nm AS string)              AS position_nm,
    ip_al_id_scms.identification_nbr                  AS identification_nbr,
    NULL                                              AS license_certificate_nbr,  -- PENDING
    CAST(sc_se_pe.appointment_dt AS date)              AS appointment_dt,
    CAST(sc_se_pe.src_stm_code AS string)             AS src_stm_code
FROM sc_se_pe
LEFT JOIN ip_al_id_scms ON sc_se_pe.sc_senior_personnel_id = ip_al_id_scms.ip_id
