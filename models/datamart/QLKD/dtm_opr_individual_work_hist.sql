/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_work_hist
* Program name: Dtm Opr Individual Work Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		claude				[BO SUNG theo dung LLD Nhom 43] Them 3
*                                       cot con thieu: individual_identification_nbr
*                                       (mapping dong 3, uu tien NATIONAL_ID,
*                                       fallback ma type con lai cua atomic
*                                       SCMS_SC_FIRM_SENIOR_PERSONNEL - atomic
*                                       atm_ip_alternative_identification_scms_
*                                       sc_firm_senior_personnel dat ten type la
*                                       LEGACY_NATIONAL_ID cho ID_NUMBER, khong
*                                       phai literal 'IDENTIFICATION' nhu mapping
*                                       mo ta - dung dung gia tri atomic thuc te),
*                                       dismissal_dt (mapping dong 7, truc tiep
*                                       atm_sc_senior_personnel.dismissal_dt - cot
*                                       da co san trong atomic), personnel_status_code
*                                       (mapping dong 10, truc tiep atm_sc_senior_
*                                       personnel.personnel_status_code - cot da co
*                                       san trong atomic). Giu nguyen resignation_dt/
*                                       employment_status_code de tuong thich flat
*                                       da co (mapping ghi ro BA STT 43 khong dung 2
*                                       cot nay nhung giu lai).
*--------------------------------------------------------------------*
*/

WITH sc_se_pe AS (
    SELECT
        sc_senior_personnel_id,
        sc_senior_personnel_code,
        sc_code,
        position_nm,
        work_start_dt,
        dismissal_dt,
        resignation_dt,
        personnel_status_code,
        src_stm_code,
        CASE
            WHEN resignation_dt IS NULL THEN 'CURRENT'
            ELSE 'PAST'
        END AS employment_status_code
    FROM {{ ref('atm_sc_senior_personnel') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

ip_al_id_national AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
)

SELECT
    CAST(sc_se_pe.sc_senior_personnel_code AS string) AS sc_senior_personnel_code,
    CAST(ip_al_id_national.identification_nbr AS string) AS individual_identification_nbr,
    CAST(sc_se_pe.sc_code AS string)                  AS sc_code,
    CAST(sc_se_pe.position_nm AS string)              AS position_nm,
    CAST(sc_se_pe.work_start_dt AS date)              AS work_start_dt,
    CAST(sc_se_pe.dismissal_dt AS date)               AS dismissal_dt,
    CAST(sc_se_pe.resignation_dt AS date)             AS resignation_dt,
    CAST(sc_se_pe.employment_status_code AS string)   AS employment_status_code,
    CAST(sc_se_pe.personnel_status_code AS string)    AS personnel_status_code,
    CAST(sc_se_pe.src_stm_code AS string)             AS src_stm_code
FROM sc_se_pe
LEFT JOIN ip_al_id_national
    ON  ip_al_id_national.ip_id = sc_se_pe.sc_senior_personnel_id
