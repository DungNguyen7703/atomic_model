/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_examination_team_target_activity
* Program name: Fact Examination Team Target Activity
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Bo sung cot ky thuat data_dt (yyyy-MM-dd) - dung lam
*                       partition_by moi (append) va la cot loc/xoa
*                       duy nhat cho tang flat ClickHouse
* 2026-09-28   tuan.nguyenvanb   [LLD moi tu Data Modeler] Doi ten cot
*                       calendar_dt_dim_id -> decision_dt_dim_id (khong doi
*                       logic/gia tri, chi doi ten cho dung ngu nghia). Bat
*                       lai dieu kien loc ngay nghiep vu decision_dt =
*                       :etl_date (truoc do bi comment, khong loc gi ca).
* 2026-09-28b  tuan.nguyenvanb   [TAM THOI - theo yeu cau] Comment lai
*                       dieu kien decision_dt = :etl_date de 1 lan chay bat
*                       ky ngay nao cung ra DU TOAN BO lich su. CANH BAO:
*                       model la incremental_rebase/append, partition
*                       theo data_dt (ngay CHAY, khong phai decision_dt) -
*                       neu de nguyen chay hang ngay lau dai, MOI ngay se
*                       ghi DU BAN SAO toan bo lich su vao partition ngay
*                       do -> phinh du lieu vo han. Chi dung tam cho 1 lan
*                       load, nho BAT LAI dieu kien nay truoc khi van hanh
*                       chay hang ngay that.
*--------------------------------------------------------------------*
*/

WITH ex_te_tg AS (
    SELECT
        examination_team_target_code,
        examination_team_id,
        examination_team_code
    FROM {{ ref('atm_examination_team_target') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM_TARGET'
),

-- dtm_examination_team_dim không expose decision_dt nên phải join thẳng vào atomic để lấy cột này
ex_te AS (
    SELECT
        examination_team_id,
        decision_dt
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    CAST(date_format(ex_te.decision_dt, 'yyyyMMdd') AS STRING)       AS decision_dt_dim_id,
    CAST(ettd.examination_team_target_dim_id AS string)              AS examination_team_target_dim_id,
    CAST(etd.examination_team_dim_id AS string)                      AS examination_team_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt
FROM ex_te_tg
INNER JOIN ex_te
    ON ex_te.examination_team_id = ex_te_tg.examination_team_id
LEFT JOIN {{ ref('dtm_examination_team_target_dim') }}_hstr ettd
    ON ettd.examination_team_target_code = ex_te_tg.examination_team_target_code
    AND ettd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND ettd.ds_rcrd_st = 'ACTIVE'
LEFT JOIN {{ ref('dtm_examination_team_dim') }}_hstr etd
    ON etd.examination_team_code = ex_te_tg.examination_team_code
    AND etd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND etd.ds_rcrd_st = 'ACTIVE'
