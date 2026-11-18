/*
*--------------------------------------------------------------------*
* Program code: dtm_penalty_decision_dim
* Program name: Dtm Penalty Decision Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Bo sung cot violation_behavior_nm theo LLD moi
*                       (2 nhanh LEFT JOIN, fallback 'Khac').
*
* !!! TODO - CHUA SUA, UU TIEN SAU !!! (2026-09-29, phat hien qua dbt run
* loi "[SCD4A] DUPLICATE KEY DETECTED: 20 key(s) bi dup", model=
* penalty_decision_dim, etl_date=2026-09-28)
* Atomic model atm_penalty_decision_x_violation_record_relationship GIO DA TON TAI
* (scd2, unique_key=[pd_id, violation_record_id] - bridge 1-NHIEU that,
* 1 quyet dinh co the lien ket nhieu vu viec/vi pham). Nhanh phu pdvr ->
* vr -> vrb -> vb2 (dong 66-101) join xuong grain 1-nhieu nay roi join
* nguoc lai pe_de (grain 1 dong/pd_code) MA KHONG dedupe/aggregate truoc
* => fan-out: 1 pd_code co N vi pham se ra N dong, trong khi
* penalty_decision_dim_id (surrogate key chi theo pd_code) bat buoc
* unique => SCD4A chan lai (20 key dup).
* Fix dung (theo dung huong da du kien ban dau): dedupe nhanh phu ve
* dung 1 dong/pd_id truoc khi join lai (vd ROW_NUMBER() OVER (PARTITION
* BY pd_id ORDER BY ...) WHERE rn=1, chi lay 1 hanh vi vi pham dai
* dien), TUONG TU can ra soat lai nhanh chinh (pd_su_be) xem co fan-out
* giong vay khong (1 quyet dinh co the co nhieu pd_subject/
* pd_subject_behavior).
* 2026-09-29   tuan.nguyenvanb   [DA XAC MINH BANG DU LIEU THAT] Chay 2
*                       cau check tren atomic: nhanh chinh (pd_subject_
*                       behavior) ra dung 20 pd_id co >=2 violation_
*                       behavior_id phan biet - KHOP CHINH XAC voi loi "20
*                       key(s) bi dup". Nhanh phu (violation_record_
*                       behavior) cung co 3 pd_id fan-out, TRUNG voi 3/20
*                       pd_code cua nhanh chinh. Day la DU LIEU NGHIEP VU
*                       THAT (1 quyet dinh/vu viec co nhieu hanh vi vi
*                       pham that), KHONG PHAI loi source/ETL - khong co
*                       cach "doi combo key" nao tranh duoc, bat buoc
*                       phai gom ve 1 dong/pd_code (dung y do thiet ke LLD
*                       - CASE WHEN vb ELSE vb2 ELSE 'Khac' von di da ngam
*                       dinh chi lay 1 gia tri dai dien). FIX: tach rieng
*                       2 nhanh thanh 2 CTE GROUP BY pd_id (main_behavior/
*                       secondary_behavior) LAY MAX(violation_behavior_nm)
*                       lam dai dien, roi moi LEFT JOIN ca 2 vao pe_de -
*                       KHONG duoc de 2 nhanh JOIN NOI TIEP nhau nhu code
*                       cu (gay nhan TICH Cartesian giua 2 nhanh, con te
*                       hon ca cong don).
* 2026-11-03   tuan.nguyenvanb   [LLD 2026-11-03, BA O_TT_24] Doi nhan fallback violation_behavior_nm 'Khac' -> 'Khong xac dinh'.
*                       Cot/kieu khong doi; fct_penalty_decision_subject_behavior.violation_behavior_group_nm ke thua gia tri nay.
*--------------------------------------------------------------------*
*/

WITH pe_de AS (
    SELECT
        pd_id,
        pd_code,
        src_stm_code
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
),

-- ===== Nhanh chinh: qua Penalty Decision Subject -> Subject Behavior =====
pe_de_su AS (
    SELECT
        pd_subject_id,
        pd_id
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
),

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
),

-- [SUA 2026-09-29] 1 quyet dinh/vu viec co THAT nhieu hanh vi vi pham
-- (du lieu nghiep vu that, da xac minh - xem changelog dau file) - gom
-- ve dung 1 dong/pd_id TRUOC khi join lai, lay 1 gia tri dai dien
-- (MAX - bat ky gia tri nao trong tap, khong uu tien theo tieu chi cu
-- the vi LLD chi can "co gia tri" de fallback, khong yeu cau dung thu
-- tu uu tien).
main_behavior AS (
    SELECT
        pe_de_su.pd_id,
        MAX(vb.violation_behavior_nm) AS violation_behavior_nm
    FROM pe_de_su
    LEFT JOIN pd_su_be
        ON pd_su_be.pd_subject_id = pe_de_su.pd_subject_id
    LEFT JOIN vb
        ON vb.violation_behavior_id = pd_su_be.violation_behavior_id
    GROUP BY pe_de_su.pd_id
),

secondary_behavior AS (
    SELECT
        pdvr.pd_id,
        MAX(vb2.violation_behavior_nm) AS violation_behavior_nm
    FROM pdvr
    LEFT JOIN vr
        ON vr.violation_record_id = pdvr.violation_record_id
    LEFT JOIN vrb
        ON vrb.violation_record_id = vr.violation_record_id
    LEFT JOIN vb2
        ON vb2.violation_behavior_id = vrb.violation_behavior_id
    GROUP BY pdvr.pd_id
)

SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION', 'pe_de.pd_code') }} AS string) AS penalty_decision_dim_id,
    CAST(pe_de.pd_code AS string)                                            AS penalty_decision_code,
    CAST(
        CASE
            WHEN main_behavior.violation_behavior_nm IS NOT NULL THEN main_behavior.violation_behavior_nm
            WHEN secondary_behavior.violation_behavior_nm IS NOT NULL THEN secondary_behavior.violation_behavior_nm
            ELSE 'Không xác định'
        END
    AS string)                                                               AS violation_behavior_nm,
    CAST(pe_de.src_stm_code AS string)                                       AS src_stm_code
FROM pe_de
LEFT JOIN main_behavior
    ON main_behavior.pd_id = pe_de.pd_id
LEFT JOIN secondary_behavior
    ON secondary_behavior.pd_id = pe_de.pd_id
