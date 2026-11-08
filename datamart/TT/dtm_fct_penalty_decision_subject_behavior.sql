/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_penalty_decision_subject_behavior
* Program name: Fact Penalty Decision Subject Behavior
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Fix theo LLD "O_TT_16" (sua 2026-08-15): dao chieu
*                       driving table tu pd_subject_behavior sang
*                       penalty_decision, INNER JOIN -> LEFT JOIN xuong
*                       penalty_decision_subject/pd_subject_behavior de
*                       QD khong co Subject/Subject Behavior van co mat
*                       tren Fact. penalty_decision_dim_id lookup pd_code
*                       truc tiep tu penalty_decision (khong qua
*                       penalty_decision_subject nua).
* 2026-08-18   Claude   Bo sung cot ky thuat data_dt (yyyy-MM-dd) - dung lam
*                       partition_by moi (append) va la cot loc/xoa
*                       duy nhat cho tang flat ClickHouse
* 2026-09-28   tuan.nguyenvanb   [LLD moi tu Data Modeler] Doi ten cot
*                       calendar_dt_dim_id -> issued_dt_dim_id (khong doi
*                       logic/gia tri). Bat lai dieu kien loc ngay nghiep vu
*                       issued_dt = :etl_date (truoc do bi comment, khong
*                       loc gi ca).
* 2026-09-28b  tuan.nguyenvanb   [TAM THOI - theo yeu cau] Comment lai
*                       dieu kien issued_dt = :etl_date de 1 lan chay bat
*                       ky ngay nao cung ra DU TOAN BO lich su. CANH BAO:
*                       model la incremental_rebase/append, partition
*                       theo data_dt (ngay CHAY, khong phai issued_dt) -
*                       neu de nguyen chay hang ngay lau dai, MOI ngay se
*                       ghi DU BAN SAO toan bo lich su vao partition ngay
*                       do -> phinh du lieu vo han. Chi dung tam cho 1 lan
*                       load, nho BAT LAI dieu kien nay truoc khi van hanh
*                       chay hang ngay that.
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, Dev #1 Nhom 13, K_TT_46/47] BA xac nhan 1 QD co the xu phat
*                       NHIEU hanh vi -> COUNT QD, GROUP BY hanh vi. Them cot vat ly violation_behavior_group_nm
*                       (sau applied_fine_amt, truoc data_dt) = COALESCE(ten hanh vi cua dong hanh vi
*                       [penalty_decision_subject_behavior_dim], ten dai dien cua QD [penalty_decision_dim:
*                       nhanh phu hoac 'Khac']). QD co N hanh vi duoc dem o N nhom. Model INSERT theo VI TRI
*                       (append) -> ALTER TABLE ADD COLUMN ... AFTER applied_fine_amt (xem
*                       scratch/alter_tt_lld_20261001.sql).
*--------------------------------------------------------------------*
*/

WITH pe_de AS (
    SELECT
        pd_id,
        pd_code,
        issued_dt
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
        --AND issued_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

pe_de_su AS (
    SELECT
        pd_subject_id,
        pd_id,
        pd_subject_code
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
        AND pd_id IS NOT NULL
),

pd_su_be AS (
    SELECT
        pd_subject_behavior_code,
        pd_subject_id,
        applied_fine_amt
    FROM {{ ref('atm_pd_subject_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR'
)

SELECT
    CAST(date_format(pe_de.issued_dt, 'yyyyMMdd') AS STRING)                                    AS issued_dt_dim_id,
    CAST(pdsbd.penalty_decision_subject_behavior_dim_id AS string)       AS penalty_decision_subject_behavior_dim_id,
    CAST(pdd.penalty_decision_dim_id AS string)                          AS penalty_decision_dim_id,
    CAST(pdsd.penalty_decision_subject_dim_id AS string)                 AS penalty_decision_subject_dim_id,
    CAST(pd_su_be.applied_fine_amt AS decimal(23,2))                    AS applied_fine_amt,
    CAST(COALESCE(pdsbd.violation_behavior_nm, pdd.violation_behavior_nm) AS string) AS violation_behavior_group_nm,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt
FROM pe_de
LEFT JOIN pe_de_su
    ON pe_de_su.pd_id = pe_de.pd_id
LEFT JOIN pd_su_be
    ON pd_su_be.pd_subject_id = pe_de_su.pd_subject_id
LEFT JOIN {{ ref('dtm_penalty_decision_subject_behavior_dim') }}_hstr pdsbd
    ON pdsbd.penalty_decision_subject_behavior_code = pd_su_be.pd_subject_behavior_code
    AND pdsbd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pdsbd.ds_rcrd_st = 'ACTIVE'
LEFT JOIN {{ ref('dtm_penalty_decision_dim') }}_hstr pdd
    ON pdd.penalty_decision_code = pe_de.pd_code
    AND pdd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pdd.ds_rcrd_st = 'ACTIVE'
LEFT JOIN {{ ref('dtm_penalty_decision_subject_dim') }}_hstr pdsd
    ON pdsd.penalty_decision_subject_code = pe_de_su.pd_subject_code
    AND pdsd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pdsd.ds_rcrd_st = 'ACTIVE'
