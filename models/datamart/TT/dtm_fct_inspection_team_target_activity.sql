/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_inspection_team_target_activity
* Program name: Fact Inspection Team Target Activity
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
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA Nhom 4] Doi DRIVING sang inspection_team (atm_inspection_team),
*                       LEFT JOIN inspection_team_target: doan thanh tra CHUA GAN DOI TUONG van len du 1 dong
*                       (inspection_team_target_dim_id = NULL). Truoc day driving = target + INNER JOIN team nen
*                       doan chua co doi tuong bi mat. Cot dau ra KHONG doi (chi FK doi tuong thanh nullable) ->
*                       khong can ALTER mart. Flat tt_fct_inspection_team_target_activity_flat doi JOIN target_dim
*                       thanh LEFT JOIN.
*--------------------------------------------------------------------*
*/

WITH in_te_tg AS (
    SELECT
        inspection_team_target_code,
        inspection_team_id
    FROM {{ ref('atm_inspection_team_target') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM_TARGET'
),

-- dtm_inspection_team_dim không expose decision_dt nên phải join thẳng vào atomic để lấy cột này
in_te AS (
    SELECT
        inspection_team_id,
        inspection_team_code,
        decision_dt
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    CAST(date_format(in_te.decision_dt, 'yyyyMMdd') AS STRING)                               AS decision_dt_dim_id,
    CAST(ittd.inspection_team_target_dim_id AS string)              AS inspection_team_target_dim_id,
    CAST(itd.inspection_team_dim_id AS string)                      AS inspection_team_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt
FROM in_te
LEFT JOIN in_te_tg
    ON in_te_tg.inspection_team_id = in_te.inspection_team_id
LEFT JOIN {{ ref('dtm_inspection_team_target_dim') }}_hstr ittd
    ON ittd.inspection_team_target_code = in_te_tg.inspection_team_target_code
    AND ittd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND ittd.ds_rcrd_st = 'ACTIVE'
LEFT JOIN {{ ref('dtm_inspection_team_dim') }}_hstr itd
    ON itd.inspection_team_code = in_te.inspection_team_code
    AND itd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND itd.ds_rcrd_st = 'ACTIVE'
