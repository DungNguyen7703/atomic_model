/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_penalty_decision_subject
* Program name: Fact Penalty Decision Subject
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
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
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA Nhom 14] Doi DRIVING sang penalty_decision, LEFT JOIN
*                       penalty_decision_subject: QD CHUA CO DOI TUONG van len du 1 dong
*                       (penalty_decision_subject_dim_id = NULL). Cot dau ra KHONG doi (FK doi tuong thanh
*                       nullable) -> khong can ALTER mart. Flat tt_fct_penalty_decision_subject_flat doi JOIN
*                       subject_dim thanh LEFT JOIN.
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        pd_subject_code,
        pd_id
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
),

-- dtm_penalty_decision_dim không expose issued_dt nên phải join thẳng vào atomic để lấy cột này
pe_de AS (
    SELECT
        pd_id,
        pd_code,
        issued_dt
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
        --AND issued_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    CAST(date_format(pe_de.issued_dt, 'yyyyMMdd') AS STRING)                               AS issued_dt_dim_id,
    CAST(pdsd.penalty_decision_subject_dim_id AS string)            AS penalty_decision_subject_dim_id,
    CAST(pdd.penalty_decision_dim_id AS string)                     AS penalty_decision_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt
FROM pe_de
LEFT JOIN pe_de_su
    ON pe_de_su.pd_id = pe_de.pd_id
LEFT JOIN {{ ref('dtm_penalty_decision_subject_dim') }}_hstr pdsd
    ON pdsd.penalty_decision_subject_code = pe_de_su.pd_subject_code
    AND pdsd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pdsd.ds_rcrd_st = 'ACTIVE'
LEFT JOIN {{ ref('dtm_penalty_decision_dim') }}_hstr pdd
    ON pdd.penalty_decision_code = pe_de.pd_code
    AND pdd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pdd.ds_rcrd_st = 'ACTIVE'
