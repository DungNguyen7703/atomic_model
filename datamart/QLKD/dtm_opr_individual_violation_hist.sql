/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_violation_hist
* Program name: Dtm Opr Individual Violation Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		claude				[SUA theo LLD moi nhat, BA STT 44] Doi
*                                       PK tu pd_code sang pd_subject_behavior_
*                                       code (grain 1 hanh vi x 1 ca nhan x 1
*                                       quyet dinh). pd_code gio la thuoc tinh.
*                                       Bo sung cot violation_description tu
*                                       pd_subject_behavior.description.
* 2026-10-19		claude				[CAP NHAT] atm_penalty_decision da
*                                       duoc bo sung vao models/atomic
*                                       (event/atm_penalty_decision.sql,
*                                       materialized: scd4a). Da doi chieu:
*                                       output dung du cot ma model nay dang
*                                       dung (pd_id, decision_nbr, issued_dt,
*                                       violation_case_id) - khong can sua
*                                       logic SQL cho phan nay.
*                                       GAP ATOMIC CON LAI: ref('atm_violation_
*                                       case') (dung cho CTE vi_ca / cot
*                                       decision_status_code) - model nay VAN
*                                       CHUA TON TAI trong working tree hien
*                                       tai (chi co ban nam ngoai pham vi o
*                                       .claude/worktrees) -> model nay van
*                                       chua the dbt run cho toi khi Atomic
*                                       bo sung them atm_violation_case.
* 2026-10-25		tuan.nguyenvanb		[LLD atomic THANHTRA] Atomic doi ten cot penalty_tp_id -> cl_thanhtra_penalty_tp_id (pd_subject_behavior, cl_thanhtra_penalty_type) ; chi doi ten cot doc tu atomic,
*                                       cot output mart khong doi -> khong ALTER mart/ClickHouse.
* 2026-10-25		tuan.nguyenvanb		[LLD atomic THANHTRA] Bo atm_penalty_type (ten cu), doc atm_cl_thanhtra_penalty_type (LLD chi co entity cl_thanhtra_penalty_type): penalty_tp_id/nm -> cl_thanhtra_penalty_tp_id/nm.
*                                       Cot output mart khong doi -> khong ALTER mart/ClickHouse.
* 2026-10-25		tuan.nguyenvanb		[DESIGN tra loi, BA chot] Bo cot violation_description (atomic pd_subject_behavior bo description). CAN ALTER DROP COLUMN violation_description o mart (main + _hstr); flat khong dung cot nay.
* 2026-10-25		tuan.nguyenvanb		[BA chot] Hinh thuc xu phat INACTIVE (loc ACTIVE o ODS): van hien thi xu phat voi ten hinh thuc NULL -> JOIN pe_ty doi thanh LEFT JOIN + WHERE giu logic chi lay PRIMARY_PENALTY.
* 2026-10-29		tuan.nguyenvanb		[SUA theo dung LLD, ket qua ra soat doi chieu Mapping - xac nhan user]
*                                       Design moi nhat (datamart_model.yaml + LLD CSV, cap nhat 2026-10-28)
*                                       ghi ro violation_description PHAI co, nguon pd_subject_behavior.
*                                       description - ghi de quyet dinh "bo cot" ngay 2026-10-25. Phat hien
*                                       cot description cung da bi bo khoi atm_pd_subject_behavior.sql (tang
*                                       atomic) cung ngay 2026-10-25; da sua dong thoi atomic (them lai cot,
*                                       du lieu nguon van co san o ODS) de co the them cot nay vao day. CAN
*                                       ALTER ADD COLUMN violation_description o mart that (main + _hstr).
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        pd_code,
        subject_id_nbr,
        pd_id,
        pd_subject_id,
        src_stm_code
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND subject_tp_code = 'INDIVIDUAL'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
),

pe_de AS (
    SELECT
        pd_id,
        decision_nbr,
        issued_dt,
        violation_case_id
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
),

vi_ca AS (
    SELECT
        violation_case_id,
        life_cycle_status_code
    FROM {{ ref('atm_violation_case') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_CASE'
),

pd_su_be AS (
    SELECT
        pd_subject_behavior_code,
        pd_subject_id,
        violation_behavior_id,
        cl_thanhtra_penalty_tp_id,
        --description
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
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
),

pe_ty AS (
    SELECT
        cl_thanhtra_penalty_tp_id,
        cl_thanhtra_penalty_tp_nm
    FROM {{ ref('atm_cl_thanhtra_penalty_type') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_TYPE'
        AND penalty_category_code = 'PRIMARY_PENALTY'
)

SELECT
    CAST(pd_su_be.pd_subject_behavior_code AS string) AS pd_subject_behavior_code,
    CAST(pe_de_su.pd_code AS string)              AS pd_code,
    CAST(pe_de_su.subject_id_nbr AS string)       AS identification_nbr,
    CAST(pe_de.decision_nbr AS string)            AS decision_nbr,
    CAST(pe_de.issued_dt AS date)                 AS issued_dt,
    --CAST(pd_su_be.description AS string)          AS violation_description,
    CAST(vi_be.violation_behavior_nm AS string)   AS violation_behavior_nm,
    CAST(pe_ty.cl_thanhtra_penalty_tp_nm AS string)           AS penalty_tp_nm,
    CAST(vi_ca.life_cycle_status_code AS string)  AS decision_status_code,
    CAST(pe_de_su.src_stm_code AS string)         AS src_stm_code
FROM pe_de_su
JOIN pe_de
    ON  pe_de.pd_id = pe_de_su.pd_id
LEFT JOIN vi_ca
    ON  vi_ca.violation_case_id = pe_de.violation_case_id
JOIN pd_su_be
    ON  pd_su_be.pd_subject_id = pe_de_su.pd_subject_id
JOIN vi_be
    ON  vi_be.violation_behavior_id = pd_su_be.violation_behavior_id
LEFT JOIN pe_ty
    ON  pe_ty.cl_thanhtra_penalty_tp_id = pd_su_be.cl_thanhtra_penalty_tp_id
-- [BA chot 2026-10-25] Hinh thuc xu phat INACTIVE (ODS da loc ACTIVE) -> cl_thanhtra_penalty_tp_id NULL: van hien thi xu phat, ten hinh thuc = NULL.
-- Van chi lay hinh thuc PRIMARY_PENALTY: bo cac dong co hinh thuc ACTIVE nhung khong phai PRIMARY_PENALTY (pe_ty khong khop).
WHERE pe_ty.cl_thanhtra_penalty_tp_id IS NOT NULL
    OR pd_su_be.cl_thanhtra_penalty_tp_id IS NULL
