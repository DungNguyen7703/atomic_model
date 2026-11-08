/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_petition_list
* Program name: Operational Petition List
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-29   tuan.nguyenvanb   [FIX - theo yeu cau BA] Loi "[SCD4A]
*                       DUPLICATE KEY DETECTED: 1 key(s) bi dup", model=
*                       opr_petition_list, etl_date=2026-09-28. Nguyen
*                       nhan: sau khi atm_petition doi khoa sinh petition_id
*                       sang dung `id` (thay vi `code`) de giu du toan bo
*                       ban ghi nguon (ke ca 161 dong code=NULL), cac dong
*                       nay chay xuong day va gop thanh "1 key bi dup" o
*                       dung unique_key=petition_code cua model nay (NULL=
*                       NULL khi GROUP BY). BA muon giu nguyen du lieu,
*                       KHONG loai code=NULL - doi unique_key sang dung
*                       petition_id (lay thang tu atm_petition, da unique
*                       theo id nguon) thay cho petition_code. petition_code
*                       van giu lai lam thuoc tinh hien thi (co the NULL).
*                       CAN doi ca unique_key trong schema_dtm_tt.yml va
*                       ALTER TABLE them cot petition_id (model scd4a insert
*                       theo ten cot qua danh sach tuong minh nen them cot
*                       moi an toan, khong lech vi tri).
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, Dev #2] Them cot target_nm (Ten doi tuong cua don,
*                       petition.target_nm <- THANHTRA.PETITION.TARGET_NAME) sau content - dung tam cho K_TT_68
*                       (Doi tuong) trong khi cho Atomic Petition Target (O_TT_22). petition_id da la unique_key
*                       tu 2026-09-29; petition_code chi con la thuoc tinh hien thi (nullable). scd4a insert theo
*                       TEN cot -> ADD COLUMN an toan (xem scratch/alter_tt_lld_20261001.sql).
*--------------------------------------------------------------------*
*/

WITH peti AS (
    SELECT
        petition_id,
        petition_code,
        petition_category_code,
        content,
        target_nm,
        life_cycle_status_code,
        received_dt,
        src_stm_code
    FROM {{ ref('atm_petition') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PETITION'
)

SELECT
    CAST(peti.petition_id AS string)             AS petition_id,
    CAST(peti.petition_code AS string)          AS petition_code,
    CAST(peti.petition_category_code AS string) AS petition_category_code,
    CAST(peti.content AS string)                AS content,
    CAST(peti.target_nm AS string)              AS target_nm,
    CAST(peti.life_cycle_status_code AS string) AS life_cycle_status_code,
    CAST(peti.received_dt AS date)              AS received_dt,
    CAST(YEAR(peti.received_dt) AS int)         AS received_year,
    CAST(peti.src_stm_code AS string)           AS src_stm_code
FROM peti
