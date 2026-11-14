/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_investor_compliance_hist
* Program name: Dtm Opr Investor Compliance Hist
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date    User    Description
* 2026-10-26  nghia.le  [FIX] Dong bo LLD: cot description phai lay tu violation_behavior.description
*         (LEFT JOIN pd_subject_behavior -> violation_behavior theo violation_behavior_id), khong
*         phai pd_subject_behavior.description (mo ta rieng theo quyet dinh xu phat, khac ngu nghia
*         voi mo ta chuan hoa cua hanh vi vi pham ma LLD yeu cau).
* 2026-10-01  nghia.le  Dong bo LLD 2026-10-01: driving pd_subject, LEFT JOIN
*         pd_subject_behavior, INNER JOIN penalty_decision, LEFT JOIN
*         penalty_type; PK = COALESCE(behavior_code, subject_code);
*         them subject_id_nbr (da masked tu nguon); src_stm_code
*         lay tu pd_subject.
*--------------------------------------------------------------------*
*/

WITH pd_su AS (
    SELECT
        pd_subject_id,
        pd_subject_code,
        pd_id,
        subject_nm,
        subject_id_nbr,
        src_stm_code
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
),

pd_su_be AS (
    SELECT
        pd_subject_behavior_code,
        violation_behavior_id,
        pd_subject_id,
        cl_thanhtra_penalty_tp_id
    FROM {{ ref('atm_pd_subject_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR'
),

vi_be AS (
    SELECT
        violation_behavior_id,
        violation_behavior_nm
    FROM {{ ref('atm_violation_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
),

pe_de AS (
    SELECT
        pd_id,
        issued_dt,
        life_cycle_status_code
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
),

pe_ty AS (
    SELECT
        cl_thanhtra_penalty_tp_id,
        cl_thanhtra_penalty_tp_nm
    FROM {{ ref('atm_cl_thanhtra_penalty_type') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_TYPE'
)

SELECT
    CAST(COALESCE(pd_su_be.pd_subject_behavior_code, pd_su.pd_subject_code) AS string) AS investor_compliance_hist_code,
    CAST(pd_su.subject_nm AS string)                  AS subject_nm,
    CAST(pd_su.subject_id_nbr AS string)              AS subject_id_nbr,
    CAST(pe_de.issued_dt AS date)                     AS issued_dt,
    CAST(pe_ty.cl_thanhtra_penalty_tp_nm AS string)   AS penalty_tp_nm,
    CAST(vi_be.violation_behavior_nm AS string)                 AS description,
    CAST(pe_de.life_cycle_status_code AS string)      AS life_cycle_status_code,
    CAST(pd_su.src_stm_code AS string)                AS src_stm_code
FROM pd_su
LEFT JOIN pd_su_be
    ON  pd_su_be.pd_subject_id = pd_su.pd_subject_id
JOIN pe_de
    ON  pe_de.pd_id = pd_su.pd_id
LEFT JOIN pe_ty
    ON  pe_ty.cl_thanhtra_penalty_tp_id = pd_su_be.cl_thanhtra_penalty_tp_id
LEFT JOIN vi_be
    ON  vi_be.violation_behavior_id = pd_su_be.violation_behavior_id
 