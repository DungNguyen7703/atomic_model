/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_penalty_decision
* Program name: Fact Penalty Decision
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Bo sung cot ky thuat data_dt (yyyy-MM-dd) - dung lam
*                       partition_by moi (append) va la cot loc/xoa
*                       duy nhat cho tang flat ClickHouse
* 2026-09-28   tuan.nguyenvanb   [LLD moi tu Data Modeler] (1) Doi ten cot
*                       calendar_dt_dim_id -> issued_dt_dim_id (khong doi
*                       logic/gia tri). (2) Bat lai dieu kien loc ngay
*                       nghiep vu issued_dt = :etl_date (truoc do bi comment,
*                       khong loc gi ca). (3) Them measure moi paid_fine_amt
*                       = SUM(pd_subject.paid_amt) theo pd_id, chen dung vi
*                       tri sau total_fine_amt (xem DDL ALTER kem theo -
*                       model nay la incremental_rebase/append, insert theo
*                       VI TRI cot, phai ALTER ADD COLUMN ... AFTER dung cho
*                       khop).
* 2026-09-28b  tuan.nguyenvanb   [TAM THOI - theo yeu cau] Comment lai
*                       dieu kien issued_dt = :etl_date de 1 lan chay bat
*                       ky ngay nao cung ra DU TOAN BO lich su (khong con
*                       la transaction log 1 dong/ngay theo dung LLD nua).
*                       CANH BAO: model la incremental_rebase/append,
*                       partition theo data_dt (ngay CHAY, khong phai
*                       issued_dt) - neu de nguyen va chay hang ngay lau
*                       dai, MOI ngay se ghi DU BAN SAO toan bo lich su
*                       vao partition ngay do -> phinh du lieu vo han.
*                       Chi dung tam cho 1 lan load du lieu, nho BAT LAI
*                       dieu kien nay truoc khi van hanh chay hang ngay
*                       that.
*--------------------------------------------------------------------*
*/

WITH pe_de AS (
    SELECT
        pd_id,
        pd_code,
        issued_dt,
        total_fine_amt
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
        --AND issued_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

pd_su_paid AS (
    SELECT
        pd_id,
        SUM(paid_amt) AS paid_fine_amt
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
    GROUP BY pd_id
)

SELECT
    CAST(date_format(pe_de.issued_dt, 'yyyyMMdd') AS STRING)             AS issued_dt_dim_id,
    CAST(pdd.penalty_decision_dim_id AS string)   AS penalty_decision_dim_id,
    CAST(pe_de.total_fine_amt AS decimal(23,2))   AS total_fine_amt,
    CAST(pd_su_paid.paid_fine_amt AS decimal(23,2)) AS paid_fine_amt,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt
FROM pe_de
LEFT JOIN {{ ref('dtm_penalty_decision_dim') }}_hstr pdd
    ON pdd.penalty_decision_code = pe_de.pd_code
    AND pdd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pdd.ds_rcrd_st = 'ACTIVE'
LEFT JOIN pd_su_paid
    ON pd_su_paid.pd_id = pe_de.pd_id
