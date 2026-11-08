/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_penalty_decision_list
* Program name: Operational Penalty Decision List
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Fix life_cycle_status_code: doi nguon tu
*                       penalty_decision sang violation_case, bo sung
*                       CASE WHEN map nhan tieng Viet theo LLD
* 2026-11-03   tuan.nguyenvanb   [LLD 2026-11-03, BA O_TT_25] Them cot violation_behavior_nm (PK ghep voi pd_subject_code,
*                       vi tri truoc src_stm_code). Grain = luot QD x doi tuong x hanh vi. Uu tien hanh vi cua doi tuong bi xu phat
*                       (pd_subject_behavior), fallback hanh vi cua bien ban lien ket QD (penalty_decision_x_violation_record),
*                       'Khong xac dinh' neu khong co; SELECT DISTINCT de loai trung do fan-out 2 nhanh. unique_key doi sang
*                       [pd_subject_code, violation_behavior_nm] (xem schema_dtm_tt.yml).
* 2026-11-07		tuan.nguyenvanb		Doi kieu theo atomic/ODS: total_fine_amt decimal(23,2) -> decimal(19,4).
* 2026-11-07   tuan.nguyenvanb   [LLD 2026-11-07, Detail Mapping K_TT_53/54] form_tp_code va life_cycle_status_code luu MA GOC
*                       (PERIODIC/UNSCHEDULED, NULL neu ho so khong tu doan TT/KT; NEW/PROCESSING/DECISION_ISSUED/ENFORCED/CLOSED),
*                       bo CASE WHEN map nhan tieng Viet - nhan anh xa o Detail Mapping. Ten/kieu cot khong doi, form_tp_code nullable;
*                       gia tri doi tu nhan sang ma -> can chay lai mart + flat.
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        pd_subject_id,
        pd_subject_code,
        subject_nm,
        subject_tp_code,
        total_fine_amt,
        pd_id,
        src_stm_code
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
),

pe_de AS (
    SELECT
        pd_id,
        violation_case_id,
        issued_dt
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
),

vi_ca AS (
    SELECT
        violation_case_id,
        violation_case_code,
        life_cycle_status_code,
        inspection_team_id,
        examination_team_id
    FROM {{ ref('atm_violation_case') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_CASE'
),

in_te AS (
    SELECT
        inspection_team_id,
        form_tp_code
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
),

ex_te AS (
    SELECT
        examination_team_id,
        form_tp_code
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
),

-- Hanh vi vi pham: nhanh chinh (doi tuong bi xu phat) uu tien, nhanh phu (bien ban lien ket QD) fallback
pd_su_be AS (
    SELECT
        pd_subject_id,
        violation_behavior_id
    FROM {{ ref('atm_pd_subject_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR'
),

vb AS (
    SELECT
        violation_behavior_id,
        violation_behavior_nm
    FROM {{ ref('atm_violation_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
        AND life_cycle_status_code = 'ACTIVE'
),

pdvr AS (
    SELECT
        pd_id,
        violation_record_id
    FROM {{ ref('atm_penalty_decision_x_violation_record_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_VIOLATION_RECORD'
),

vr AS (
    SELECT
        violation_record_id
    FROM {{ ref('atm_violation_record') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_RECORD'
),

vrb AS (
    SELECT
        violation_record_id,
        violation_behavior_id
    FROM {{ ref('atm_violation_record_x_violation_behavior_relationship') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_RECORD_BEHAVIOR'
),

vb2 AS (
    SELECT
        violation_behavior_id,
        violation_behavior_nm
    FROM {{ ref('atm_violation_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
        AND life_cycle_status_code = 'ACTIVE'
),

behavior_src AS (
    SELECT DISTINCT
        pe_de_su.pd_subject_id,
        CASE
            WHEN vb.violation_behavior_nm  IS NOT NULL THEN vb.violation_behavior_nm
            WHEN vb2.violation_behavior_nm IS NOT NULL THEN vb2.violation_behavior_nm
            ELSE 'Không xác định'
        END AS violation_behavior_nm
    FROM pe_de_su
    LEFT JOIN pd_su_be
        ON pd_su_be.pd_subject_id = pe_de_su.pd_subject_id
    LEFT JOIN vb
        ON vb.violation_behavior_id = pd_su_be.violation_behavior_id
    LEFT JOIN pdvr
        ON pdvr.pd_id = pe_de_su.pd_id
    LEFT JOIN vr
        ON vr.violation_record_id = pdvr.violation_record_id
    LEFT JOIN vrb
        ON vrb.violation_record_id = vr.violation_record_id
    LEFT JOIN vb2
        ON vb2.violation_behavior_id = vrb.violation_behavior_id
)

SELECT
    CAST(pe_de_su.pd_subject_code AS string)                AS pd_subject_code,
    CAST(vi_ca.violation_case_code AS string)               AS violation_case_code,
    CAST(pe_de_su.subject_nm AS string)                     AS subject_nm,
    CAST(pe_de_su.subject_tp_code AS string)                AS subject_tp_code,
    CAST(
        CASE
            WHEN vi_ca.inspection_team_id  IS NOT NULL THEN in_te.form_tp_code
            WHEN vi_ca.examination_team_id IS NOT NULL THEN ex_te.form_tp_code
            ELSE NULL
        END
    AS string)                                              AS form_tp_code,
    CAST(vi_ca.life_cycle_status_code AS string)            AS life_cycle_status_code,
    CAST(pe_de.issued_dt AS date)                           AS issued_dt,
    CAST(YEAR(pe_de.issued_dt) AS int)                      AS issued_year,
    CAST(pe_de_su.total_fine_amt AS decimal(19,4))          AS total_fine_amt,
    CAST(behavior_src.violation_behavior_nm AS string)      AS violation_behavior_nm,
    CAST(pe_de_su.src_stm_code AS string)                   AS src_stm_code
FROM pe_de_su
LEFT JOIN pe_de
    ON pe_de.pd_id = pe_de_su.pd_id
LEFT JOIN vi_ca
    ON vi_ca.violation_case_id = pe_de.violation_case_id
LEFT JOIN in_te
    ON in_te.inspection_team_id = vi_ca.inspection_team_id
LEFT JOIN ex_te
    ON ex_te.examination_team_id = vi_ca.examination_team_id
LEFT JOIN behavior_src
    ON behavior_src.pd_subject_id = pe_de_su.pd_subject_id
